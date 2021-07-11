{ lib, pkgs, config, ... }:

let
cfg = config.services.xserver.windowManager.xmonad;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      firefox mpc_cli rofi thunderbird alacritty tdesktop
    ];

    services.xserver.enable = true;
    services.xserver.windowManager.xmonad = {

      config = pkgs.substituteAll {
        src = ./xmonad.hs;
        virtualised = config.services.qemuGuest.enable;
      };

      extraPackages = hpkgs: with hpkgs; [
        xmonad-contrib
      ];
    };
  };
}
