{ config, inputs, ... }: {
  nix.settings = {
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
    n = {
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
    text = /*bash*/''
      echo "system changes:"
      ${config.nix.package}/bin/nix store diff-closures /run/current-system "$systemConfig" 
    '';
  };
}
