{ pkgs, config, inputs, lib, ... }: let
  url = url:
    let group = with builtins;
      elemAt (match "(.+):(.+)/(.+)" url);
    in {
      type = group 0;
      owner = group 1;
      repo = group 2;
    };
in {
  nix.package = pkgs.nixUnstable;
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
      "repl-flake"
    ];
    use-xdg-base-directories = true;
    warn-dirty = false;
    flake-registry = "";
  };

  # Use n as an alias to the current configs nixpkgs.
  # So you can run stuff like this: `nix run n#hello`
  nix.registry = {
    n.flake = inputs.nixpkgs;
    npkgs = { to = url "github:nixos/nixpkgs"; exact = false; };
    nw.to = url "github:nix-community/nixpkgs-wayland";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      echo "system changes:"
      ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig" 
    '';
  };
}
