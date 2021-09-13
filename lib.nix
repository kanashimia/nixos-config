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
        type == "directory" || hasSuffix ".nix" name
      ) (builtins.readDir dir)
    );

  mkOverlayTree = path:
    lib.mapAttrsRecursive (_: ovl: import ovl inputs) (mkAttrsTree path);

  listNixFilesRecursive = path:
    filter (hasSuffix ".nix") (filesystem.listFilesRecursive path);

  mkNixosConfig = path: system: name:
    makeOverridable nixosSystem {
      inherit system;

      modules = [{
        networking.hostName = name;
        nixpkgs.overlays = mkIf (inputs.self ? overlays) (
          collect (a: !isAttrs a) inputs.self.overlays
        );
      }] ++ listNixFilesRecursive path;

      specialArgs = optionalAttrs (inputs.self ? nixosModules) {
        inherit (inputs.self) nixosModules;
      } // { inherit inputs; };
    };

  mkNixosConfigs = dir:
    foldAttrs (confs: conf: confs // conf) {} (
      map (arch:
        mapAttrs (host: type:
          mkNixosConfig (dir + "/${arch}/${host}") arch host
        ) (builtins.readDir (dir + "/${arch}"))
      ) (attrNames (builtins.readDir dir))
    );
}
