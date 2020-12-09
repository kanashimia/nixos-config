{
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
