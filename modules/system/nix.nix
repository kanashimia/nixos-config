{ pkgs, inputs, ... }:

{
  # Enable flake support.
  nix.package = pkgs.nixFlakes;

  # Use n as an alias to the current configs nixpkgs.
  nix.registry.n.flake = inputs.nixpkgs;

  # Hardlink identical files in nix store.
  nix.autoOptimiseStore = true;

  # Automatically delete old generations.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
