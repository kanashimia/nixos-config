{ config, inputs, ... }: {
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

  nix.registry = {
    n.flake = inputs.nixpkgs;
    pkgs = { 
      to = { type = "github"; owner = "NixOS"; repo = "nixpkgs"; rev = inputs.nixpkgs.rev; };
      exact = false; 
    };
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
      ${config.nix.package}/bin/nix store diff-closures /run/current-system "$systemConfig" 
    '';
  };
}
