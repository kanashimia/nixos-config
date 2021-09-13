{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    chromium firefox mpc_cli rofi alacritty tdesktop
  ];

  services.xserver.enable = true;
  services.xserver.windowManager.xmonad = {
    enable = true;
    config = pkgs.substituteAll {
      src = ./xmonad.hs;
      terminal = "alacritty";
    };
    extraPackages = hpkgs: with hpkgs; [
      xmonad-contrib xmonad-systemd
    ];
  };
}
