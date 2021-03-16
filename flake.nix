{
  description = "My system config";
  
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.scroll = {
    url = "git+https://git.suckless.org/scroll";
    flake = false;
  }; 
  
  outputs = inputs: {
    nixosConfigurations = let
      inherit (inputs.nixpkgs) lib;
      hosts = with builtins; attrNames (readDir ./hosts);
      mkHost = host: lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          (./hosts + "/${host}")
          ./modules
          ./modules/themes
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    in lib.genAttrs hosts mkHost;
  };
}
