{
  description = "My system config";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    manager.url = "github:nix-community/home-manager/release-20.09";
  };
  
  outputs = { manager, ... }@inputs: {
    nixosConfigurations = with inputs.nixpkgs.lib;
      let
        conf-utils = import ./lib/conf-utils.nix;
        hosts = conf-utils.listHosts ./hosts;
        mkHost = name:
          nixosSystem {
            system = "x86_64-linux";
            modules = [
              manager.nixosModules.home-manager
              (./hosts + "/${name}.nix")
              ./profiles/system
              ./profiles/kana
            ];
            specialArgs = { inherit inputs conf-utils; };
          };
      in genAttrs hosts mkHost;
  };
}
