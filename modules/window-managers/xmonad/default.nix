{ lib, pkgs, config, ... }:

with lib;

let
cfg = config.kanashimia.xmonad;

screenshot = with pkgs; writeShellScriptBin "screenshot" ''
  ${maim}/bin/maim ~/Pictures/Screenshots/$(date +%s).png
'';

mkApp = name: val: mkOption {
  default = val;
  type = types.str;
};

apps = with pkgs; mapAttrs mkApp {
  browser = "${chromium}/bin/chromium";
  terminal = "${st}/bin/st";
  chat = "${tdesktop}/bin/telegram-desktop";
  mail = "${thunderbird}/bin/thunderbird";
  search = "${rofi}/bin/rofi -show drun -show-icons -m -4";
  screenshot = "${screenshot}/bin/screenshot";
};
in
{
  options.kanashimia.xmonad = {
    enable = mkEnableOption "custom xmonad configuration";
    inherit apps;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ firefox mpc_cli rofi ];

    services.xserver.enable = true;

    services.xserver.windowManager.xmonad = {
      enable = true;

      config = pkgs.substituteAll ({
        src = ./xmonad.hs;
        virtualised = config.services.qemuGuest.enable;
      } // cfg.apps);

      extraPackages = hpkgs: with hpkgs; [
        xmonad-contrib
      ];
    };
  };
}
