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

    agenix.url = github:ryantm/agenix;
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    mailserver.url = gitlab:simple-nixos-mailserver/nixos-mailserver;
    mailserver.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = github:nix-community/NUR;
  };
  
  outputs = inputs: {
    nixosConfigurations = let
      inherit (inputs.nixpkgs) lib;

      hosts = with builtins; attrNames (readDir ./hosts);

      listNixFilesRecursive = path: with lib;
        filter (hasSuffix ".nix")
          (filesystem.listFilesRecursive path);

      mkHost = host:
        lib.makeOverridable lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            { networking.hostName = host; }
            { nixpkgs.overlays = map import (listNixFilesRecursive ./overlays); }
            ./secrets/module.nix
            inputs.agenix.nixosModules.age
            inputs.mailserver.nixosModule
          ] ++ lib.concatMap listNixFilesRecursive [
            (./hosts + "/${host}")
            ./modules
          ];
          specialArgs = { inherit inputs; };
        };
    in lib.genAttrs hosts mkHost;
  };
}
