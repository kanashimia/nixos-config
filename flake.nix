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
  };
  
  outputs = inputs: {
    inherit (inputs.nixpkgs) legacyPackages;

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
            ./overlays
          ] ++ lib.concatMap listNixFilesRecursive [
            (./hosts + "/${host}")
            ./modules
          ];
          specialArgs = { inherit inputs; };
        };
    in lib.genAttrs hosts mkHost;
  };
}
