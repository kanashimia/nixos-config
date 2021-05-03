{
  description = "Configuration of my nixos machines.";
  
  inputs = {
    nixpkgs.url = "/home/kanashimia/nixpkgs"; # "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = inputs: {
    inherit (inputs.nixpkgs) legacyPackages;

    nixosConfigurations = let
      inherit (inputs.nixpkgs) lib;

      hosts = with builtins; attrNames (readDir ./hosts);
      listNixFilesRecursive = path: with lib; filter (hasSuffix ".nix")
        (filesystem.listFilesRecursive path);

      mkHost = host: lib.makeOverridable lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          (./hosts + "/${host}")
          ./overlays
        ] ++ lib.concatMap listNixFilesRecursive [
          ./modules
        ];
        specialArgs = { inherit inputs; };
      };
    in lib.genAttrs hosts mkHost;
  };
}
