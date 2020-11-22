{
  description = "My system config";
  
  inputs = {
    nixpkgs.url = "nixpkgs/release-20.09";
    unstable.url = "nixpkgs/master";
    manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { nixpkgs, unstable, manager, ... }@inputs: {
    nixosConfigurations = with nixpkgs.lib;
      let
        conf-utils = import ./lib/conf-utils.nix;
        hosts = conf-utils.listHosts ./hosts;
        mkHost = name:
          nixosSystem {
            system = "x86_64-linux";
            modules = [
              manager.nixosModules.home-manager
              (./hosts + "/${name}.nix")
              ./system/config.nix
            ];
            specialArgs = { inherit inputs conf-utils; };
          };
      in genAttrs hosts mkHost;
  };
}
