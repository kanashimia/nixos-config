{ pkgs, config, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox mpc_cli rofi thunderbird xst alacritty tdesktop
  ];

  services.xserver.enable = true;
  services.xserver.windowManager.xmonad = {
    enable = true;
    config = ./xmonad.hs;
    extraPackages = hpkgs: with hpkgs; [
      xmonad-contrib xmonad-systemd
    ];
  };
}
