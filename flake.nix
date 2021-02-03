{
  description = "My system config";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix.url = "github:nixos/nix";
  };
  
  outputs = { self, nixpkgs, nix }: {
    nixosConfigurations.hp-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/hp-laptop.nix
        { nixpkgs.overlays = [ nix.overlay ]; }
      ];
    };
  };
}
