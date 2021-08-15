{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox mpc_cli rofi thunderbird alacritty tdesktop
  ];

  services.xserver.enable = true;
  services.xserver.windowManager.xmonad = {
    enable = true;

    config = pkgs.substituteAll {
      src = ./xmonad.hs;
      virtualised = config.services.qemuGuest.enable;
    };

    extraPackages = hpkgs: with hpkgs; [
      xmonad-contrib
    ];
  };
}
