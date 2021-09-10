{ lib, inputs }:

with lib; rec {
  mkAttrsetTreeOfModules = dir:
    mapAttrs' (name: type: let path = dir + "/${name}"; in
      if type == "directory" then
        if pathExists (path + "/default.nix")
        then nameValuePair name (path + "/default.nix")
        else nameValuePair name (mkAttrsetTreeOfModules path)
      else nameValuePair (removeSuffix ".nix" name) path
    ) (
      filterAttrs (name: type:
        type != "regular" || hasSuffix ".nix" name
      ) (builtins.readDir dir)
    );

  listNixFilesRecursive = path:
    filter (hasSuffix ".nix") (filesystem.listFilesRecursive path);

  mkNixosConfiguration = {
    name,
    overlays ? [],
    modules ? [],
    specialArgs ? {},
    ...
  }@args: nixosSystem (
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

  mkNixosConfigurations = {
    system ? null,
    overlays ? [],
    modules ? [],
    specialArgs ? {}
  }: mapAttrs (name: val:
    mkNixosConfiguration ({
      inherit name system overlays modules specialArgs;
    } // val)
  );
}
