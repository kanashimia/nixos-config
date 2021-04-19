{ lib, pkgs, config, ... }:

with lib;

let
cfg = config.kanashimia.xmonad;

mkApp = name: val: mkOption {
  default = val;
  type = types.str;
};
apps = with pkgs; mapAttrs mkApp {
  browser = "${firefox}/bin/firefox";
  terminal = "${alacritty}/bin/alacritty";
  chat = "${tdesktop}/bin/telegram-desktop";
  mail = "${thunderbird}/bin/thunderbird";
  search = "${rofi}/bin/rofi -show drun -show-icons -m -4";
  screenshot = "${flameshot}/bin/flameshot gui";
};
in
{
  options.kanashimia.xmonad = {
    enable = mkEnableOption "custom xmonad configuration";
    inherit apps;
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;

    services.xserver.windowManager.xmonad = {
      enable = true;

      config = pkgs.substituteAll ({
        src = ./xmonad.hs;
        virtualised = config.services.qemuGuest.enable;
      } // cfg.apps);

      enableContribAndExtras = true;
    };
  };
}
