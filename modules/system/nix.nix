{ pkgs, inputs, ... }:

{
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    # Enable flake support
    experimental-features = nix-command flakes

    # Annoying warning
    warn-dirty = false

    # Disable global flake registry
    flake-registry = /etc/nix/registry.json
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
