{
  description = "Configuration of my nixos machines.";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };
  
  outputs = inputs: {
    inherit (inputs.nixpkgs) legacyPackages;
    nixosConfigurations = let
      inherit (inputs.nixpkgs) lib;
      hosts = with builtins; attrNames (readDir ./hosts);
      mkHost = host: lib.makeOverridable lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          (./hosts + "/${host}")
          ./modules
          ./modules/themes
        ];
        specialArgs = { inherit inputs; };
      };
    in lib.genAttrs hosts mkHost;
  };
}
