{ pkgs, ... }:

{
  services.xserver.enable = true;

  services.dbus.packages = with pkgs; [ flameshot ];
  environment.systemPackages = with pkgs; [ firefox ];

  services.xserver.windowManager.xmonad = {
    enable = true;

    config = with pkgs; substituteAll {
      src = ./xmonad.hs;

      browser = "${firefox}/bin/firefox";
      terminal = "${alacritty}/bin/alacritty";
      scratchpad = "${xst}/bin/xst -n scratchpad";
      chat = "${tdesktop}/bin/telegram-desktop";
      mail = "${thunderbird}/bin/thunderbird";
      search = "${rofi}/bin/rofi -show drun -show-icons -m -4";
      screenshot = "${flameshot}/bin/flameshot gui";
    };

    enableContribAndExtras = true;
    extraPackages = hpkgs: with hpkgs; [ cpuinfo ];
  };
}
