{ pkgs, ... }:

{
  # Dependancies.
  home.packages = with pkgs; [
    brillo flameshot tdesktop
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
    ${pkgs.autorandr}/bin/autorandr -c &
    ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
  '';

  xsession.pointerCursor = {
    package = pkgs.breeze-qt5;
    name = "breeze_cursors";
    size = 16;
  };

  services.unclutter.enable = true;

  home.keyboard = {
    layout = "us,ru,ua";
    options = [
      "caps:swapescape"
      "grp:rctrl_rshift_toggle"
      "compose:menu"
    ];
  };
}
