{
  description = "Configuration of my nixos machines.";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    xmonad.url = "github:xmonad/xmonad";
    xmonad.flake = false;

    xmonad-contrib.url = "github:xmonad/xmonad-contrib";
    xmonad-contrib.flake = false;

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = github:ryantm/agenix;
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    mailserver.url = gitlab:simple-nixos-mailserver/nixos-mailserver;
    mailserver.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = github:nix-community/NUR;
  };
  
  outputs = inputs: {
    #deploy.nodes.personal-server = {
    #  hostname = "redpilled.dev";
    #  sshUser = "root";

    #  profiles.system = {
    #    path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
    #      inputs.self.nixosConfigurations.personal-server;
    #  };
    #};

    # checks = builtins.mapAttrs
    #   (system: deployLib: deployLib.deployChecks inputs.self.deploy)
    #   inputs.deploy-rs.lib;
    # legacyPackages = import inputs.nur {
    #     nurpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    # };
       
    nixosConfigurations = let
      inherit (inputs.nixpkgs) lib;

      hosts = with builtins; attrNames (readDir ./hosts);

      listNixFilesRecursive = path: with lib;
        filter (hasSuffix ".nix")
          (filesystem.listFilesRecursive path);

      inputs-overlay = final: prev: { inherit inputs; };

      mkHost = host:
        lib.makeOverridable lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            { networking.hostName = host; }
            { nixpkgs.overlays = [ inputs-overlay ]; }
            inputs.agenix.nixosModules.age
            inputs.mailserver.nixosModule
            ./secrets/module.nix
            ./overlays
          ] ++ lib.concatMap listNixFilesRecursive [
            (./hosts + "/${host}")
            ./preferences
            ./profiles
          ];
          specialArgs = { inherit inputs; };
        };
    in lib.genAttrs hosts mkHost;
  };
}
