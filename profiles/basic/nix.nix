{ config, inputs, pkgs, ... }: {
  nix.package = pkgs.nixVersions.nix_2_23;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    use-xdg-base-directories = true;
    warn-dirty = false;
    flake-registry = "";
    trusted-users = [ "root" "@wheel" ];
  };

  nix.registry = {
    n = {
      to = builtins.parseFlakeRef "github:nixos/nixpkgs/${inputs.nixpkgs.rev}";
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
