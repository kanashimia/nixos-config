{ pkgs, config, ... }:

{
  # Mouse and touchpad configuration.
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      accelSpeed = "-0.1";
      naturalScrolling = true;
    };
    mouse = {
      accelSpeed = "-0.75";
      accelProfile = "flat";
    };
  };

  # Key repeat delay config.
  services.xserver = {
    autoRepeatInterval = 30;
    autoRepeatDelay = 300;
  };

  # Layout config.
  services.xserver = {
    xkbOptions = "caps:swapescape,grp:rctrl_rshift_toggle,compose:menu,grp_led:num";
    layout = "us(dvorak),ru,ua";
  };

  # i18n.inputMethod.enabled = "fcitx5";
  # i18n.inputMethod.fcitx5.addons = with pkgs; [
  #   fcitx5-mozc fcitx5-m17n fcitx5-table-other fcitx5-table-extra
  # ];
  # i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [
  #   mozc m17n table table-others
  # ];
  # services.xserver.displayManager.sessionCommands = "${config.i18n.inputMethod.package}/bin/fcitx5 -d";
  # services.xserver.displayManager.sessionCommands = "${pkgs.ibus}/bin/ibus-daemon -drx";

  # Use same layout for console. 
  console.useXkbConfig = true;
}
