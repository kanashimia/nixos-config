{ pkgs, ... }:

{
  services.xserver.windowManager.xmonad = {
    enable = true;
    config = ./xmonad.hs;
    enableContribAndExtras = true;
  };

  environment.systemPackages = with pkgs; [
    xst
  ];

  sound.mediaKeys.enable = true;
}
