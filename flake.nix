{
  description = "My system config";
  
  inputs = {
    pkgs.url = "github:NixOS/nixpkgs";
    manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "pkgs";
    };
  };
  
  outputs = { self, manager, pkgs }: {
    nixosConfigurations = let
      conf-utils = import ./lib/conf-utils.nix;
      hosts = conf-utils.listHosts ./hosts;
      mkHost = name: pkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          manager.nixosModules.home-manager
          (./hosts + "/${name}.nix")
          ./profiles/system
          ./profiles/kana
        ];
        specialArgs = {
          inherit conf-utils;
        };
      };
    in pkgs.lib.genAttrs hosts mkHost;
  };
}
