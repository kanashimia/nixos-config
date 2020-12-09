{ pkgs, ... }:

{
  # imports = [ ../xorg ];

  # Dependancies.
  home.packages = with pkgs; [
    xst unstable.rofi brillo flameshot tdesktop
  ];
  home.sessionVariables = {
    BROWSER = "vivaldi";
    EDITOR = "kak";
  };
  
  # Xmonad config.
  xsession.enable = true;
  xsession.scriptPath = ".hm-xsession";
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ./xmonad.hs;
  };
  xsession.initExtra = ''
    ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
  '';

  xsession.pointerCursor = {
    package = pkgs.breeze-qt5;
    name = "breeze_cursors";
    size = 16;
  };

  services.unclutter.enable = true;

  home.keyboard = {
    layout = "us,ru";
    options = [
      "caps:swapescape"
      "grp:rctrl_rshift_toggle"
    ];
  };
  
 # home.file.".xinitrc".text = ''
 #   #!/bin/sh
 #   ${pkgs.runtimeShell} $HOME/.xsession
 # '';
}
