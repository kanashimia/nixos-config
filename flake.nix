{
  description = "My system config";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-20.09";
    unstable.url = "nixpkgs/nixos-unstable";
    manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { nixpkgs, unstable, manager, ... }@inputs: {
    nixosConfigurations.hp-laptop = nixpkgs.lib.nixosSystem {
      modules = [
        (manager.nixosModules.home-manager)
        ./hosts/hp-laptop.nix
        ./system.nix
      ];
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
    };
    #legacyPackages.x86_64-linux = self.nixosConfigurations.hp-laptop.pkgs;
    #legacyPackages."<system>"."<attr>" = derivation;
  };
}
