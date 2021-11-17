{ pkgs, inputs, ... }: let
  emptyRegistry = pkgs.writeText "registry.json"
    (builtins.toJSON { version = 2; });
in {
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    warn-dirty = false

    # HACK: Disable global flake registry
    flake-registry = ${emptyRegistry}
  '';

  # Use n as an alias to the current configs nixpkgs.
  # So you can run stuff like this: `nix run n#hello`
  nix.registry.n.flake = inputs.nixpkgs;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  nix.autoOptimiseStore = true;
}
