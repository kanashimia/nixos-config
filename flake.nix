{
  description = "Configuration of my nixos machines.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    xmonad-systemd.url = "github:kanashimia/xmonad-systemd";
    agenix.url = "github:ryantm/agenix";

    digimend.url = "github:kurikaesu/digimend-kernel-drivers/xppen-artist22r-pro";
    digimend.flake = false;
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = inputs:  let
    inherit (inputs.nixpkgs) lib;

    genAttrsetTreeOfModules = dir: with lib;
      mapAttrs' (name: type: let path = dir + "/${name}"; in
        if type == "directory" then
          if pathExists (path + "/default.nix")
          then nameValuePair name (path + "/default.nix")
          else nameValuePair name (genAttrsetTreeOfModules path)
        else nameValuePair (removeSuffix ".nix" name) path
      ) (
        filterAttrs (name: type:
          type != "regular" || hasSuffix ".nix" name
        ) (builtins.readDir dir)
      );

    listNixFilesRecursive = path: with lib;
      filter (hasSuffix ".nix") (filesystem.listFilesRecursive path);
  in {
    nixosModules = genAttrsetTreeOfModules ./modules;

    overlays.digimend = final: prev: {
      linuxPackagesFor = kernel:
        (prev.linuxPackagesFor kernel).extend (lnxfinal: lnxprev: {
          digimend = lnxprev.digimend.overrideAttrs (old: {
            src = inputs.digimend;
            patches = [];
          });
        });
    };
     
    nixosConfigurations = let
      hosts = with builtins; attrNames (readDir ./hosts);

      mkHost = host:
        # lib.makeOverridable
        lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            { networking.hostName = host; }
            { nixpkgs.overlays = [ inputs.xmonad-systemd.overlay ]; }
            { nixpkgs.overlays = lib.attrValues inputs.self.overlays; }

            # home-manager.
            # inputs.home-manager.nixosModule
            # { home-manager.useGlobalPkgs = true; }
            # { home-manager.useUserPackages = true; }

            inputs.mailserver.nixosModule
            inputs.agenix.nixosModules.age
          ] ++ lib.concatMap listNixFilesRecursive [
            (./hosts + "/${host}")
          ];
          specialArgs = {
            inherit inputs;
            inherit (inputs.self) nixosModules;
          };
        };
    in lib.genAttrs hosts mkHost;
  };
}
