{
  description = "Configuration of my nixos machines.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";

    xmonad-systemd.url = "github:kanashimia/xmonad-systemd";
  };
  
  outputs = inputs:  let
    inherit (inputs.nixpkgs) lib;

    genAttrsetTreeOfModules = dir:
      with lib;
      mapAttrs'
        (name: type:
          let
            path = dir + "/${name}";
          in
            if type == "directory"
            then
              if pathExists (path + "/default.nix")
              then nameValuePair name (path + "/default.nix")
              else nameValuePair name (genAttrsetTreeOfModules path)
            else
              nameValuePair (removeSuffix ".nix" name) path)
        (filterAttrs
          (name: type: type != "regular" || hasSuffix ".nix" name)
          (builtins.readDir dir));

    listNixFilesRecursive = path:
      with lib;
      filter (hasSuffix ".nix")
        (filesystem.listFilesRecursive path);
  in {
    nixosModules = genAttrsetTreeOfModules ./modules;
     
    nixosConfigurations = let
      hosts = with builtins; attrNames (readDir ./hosts);

      # hosts =

      mkHost = host:
        lib.makeOverridable lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            { networking.hostName = host; }
            # { nixpkgs.overlays = map import (listNixFilesRecursive ./overlays); }
            { nixpkgs.overlays = [ inputs.xmonad-systemd.overlay ]; }

            # home-manager.
            # inputs.home-manager.nixosModule
            # { home-manager.useGlobalPkgs = true; }
            # { home-manager.useUserPackages = true; }

            inputs.mailserver.nixosModule
          ] ++ lib.concatMap listNixFilesRecursive [
            (./hosts + "/${host}")
            # ./modules
            # ./profiles
            # ./configs
          ];
          specialArgs = {
            inherit inputs;
            inherit (inputs.self) nixosModules;
          };
        };
    in lib.genAttrs hosts mkHost;
  };
}
