{ pkgs, inputs, ... }:

{
  # Enable flake support for nix, don't warn on dirty repos.
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes ca-references
    warn-dirty = false
  '';

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
