{ lib, config, pkgs, ... }:

{
  options.profiles.default.enable = lib.mkOption {
    default = true;
    example = false;
    description = "Whether to enable default profile.";
    type = lib.types.bool;
  };

  config = lib.mkIf config.profiles.minimal.enable {
    environment.systemPackages = with pkgs; [ gitMinimal kakoune ];

    nix.package = pkgs.nixUnstable;
    nix.extraOptions = ''
      experimental-features = nix-command flakes co-references
    '';

    boot.loader = {
      timeout = 0;
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
    };

    zramSwap.enable = true;

    boot.kernelParams = [ "quiet" ];
  };
}
