{ lib, inputs }:

with lib; rec {
  mkAttrsTree = dir:
    mapAttrs' (name: type: let path = dir + "/${name}"; in
      if type == "directory" then
        if pathExists (path + "/default.nix")
        then nameValuePair name (path + "/default.nix")
        else nameValuePair name (mkAttrsTree path)
      else nameValuePair (removeSuffix ".nix" name) path
    ) (
      filterAttrs (name: type:
        type != "regular" || hasSuffix ".nix" name
      ) (builtins.readDir dir)
    );

  mkOverlayTree = path:
    lib.mapAttrsRecursive (_: ovl: import ovl inputs) (mkAttrsTree path);

  listNixFilesRecursive = path:
    filter (hasSuffix ".nix") (filesystem.listFilesRecursive path);

  mkNixosConfig = {
    name,
    overlays ? [],
    modules ? [],
    specialArgs ? {},
    ...
  }@args: makeOverridable nixosSystem (
    filterAttrs (k: v: !elem k [ "name" "overlays" ]) args // {
      modules = modules ++ [{
        networking.hostName = name;
        nixpkgs.overlays = overlays;
      }] ++ concatMap listNixFilesRecursive [
        (./hosts + "/${name}")
      ];
      specialArgs = specialArgs // {
        inherit inputs;
        inherit (inputs.self) nixosModules;
      };
    }
  );

  mkNixosConfigs = {
    system ? null,
    overlays ? [],
    modules ? [],
    specialArgs ? {}
  }: mapAttrs (name: val:
    mkNixosConfig ({
      inherit name system overlays modules specialArgs;
    } // val)
  );
}
