{ config, inputs, pkgs, lib, ... }: {
  nix.package = pkgs.nixVersions.latest;
  # nix.package = pkgs.lixPackageSets.latest.lix;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      # "pipe-operator"
    ];
    # auto-optimise-store = true;
    use-xdg-base-directories = true;
    warn-dirty = false;
    flake-registry = "";
    trusted-users = [ "root" "@wheel" ];
  };

  nix.channel.enable = false;

  nix.registry = {
    "nixpkgs" = {
      to = { type = "path"; path = config.nixpkgs.flake.source; };
    };
    "n" = {
      to = { id = "nixpkgs"; type = "indirect"; };
    };
    "nn" = {
      to = builtins.parseFlakeRef "github:nixos/nixpkgs/${inputs.nixpkgs.rev}";
      exact = false;
    };
  };

  # nix.nixPath = lib.mkForce [];
  nix.nixPath = [
    "nixpkgs=${config.nixpkgs.flake.source}"
  ];

  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 30d";
  };

  system.activationScripts."diff" = {
    supportsDryActivation = true;
    text = /*bash*/''
      echo "system changes:"
      ${config.nix.package}/bin/nix store diff-closures /run/current-system "$systemConfig" 
    '';
  };
}
