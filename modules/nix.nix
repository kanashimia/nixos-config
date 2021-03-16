{ pkgs, inputs, ... }:

{
  # Enable flake and profile support.
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes ca-references
  '';

  # Use same nixpkgs systemwide.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.registry.n.flake = inputs.nixpkgs;

  # Hardlink identical files in nix store.
  nix.autoOptimiseStore = true;

  # Automatically delete old generations.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Allow unfree garbage.
  nixpkgs.config.allowUnfree = true;
}
