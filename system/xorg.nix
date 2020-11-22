{ pkgs, ...}:

{
  # General xorg config.
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    dpi = 96;
  };

  # Lightdm config.
  services.xserver.desktopManager.session = [{
    name = "xsession";
    start = ''
      ${pkgs.runtimeShell} $HOME/.xsession $
      waitPID=$!
    '';
  }];
  # services.xserver.displayManager.lightdm = {
  #   background = ../wallpaper/wallpaper.png;
  #   greeters.gtk = {
  #     indicators = [];
  #     enable = true;
  #     cursorTheme = {
  #       package = pkgs.breeze-qt5;
  #       name = "breeze_cursors";
  #       size = 16;
  #     };
  #     theme.package = pkgs.breeze-gtk;
  #     theme.name = "Breeze";
  #     iconTheme.package = pkgs.breeze-icons;
  #     iconTheme.name = "breeze";
  #   };
  # };

  # Touchpad configuration.
  # Need MatchIsTouchpad "on" there,
  # otherwise it would change mouse settings too.
  services.xserver.libinput = {
    enable = true;
    naturalScrolling = true;
    accelSpeed = "-0.1";
    additionalOptions = ''MatchIsTouchpad "on"'';
  };
  
  # Mouse config.
  services.xserver.config = ''
    Section "InputClass"
      Identifier     "My mouse"
      Driver         "libinput"
      MatchIsPointer "on"
      Option "AccelSpeed" "-0.5"
      Option "AccelProfile" "flat"
    EndSection
  '';

  # Keyboard config.
  services.xserver = {
    autoRepeatInterval = 30;
    autoRepeatDelay = 300;
  };
}
