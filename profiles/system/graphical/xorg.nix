{ pkgs, ...}:

{
  # General xorg config.
  services.xserver = {
    enable = true;
    exportConfiguration = true;
  };

  # Force dpi to const value
  services.xserver.dpi = 96;
  fonts.fontconfig.dpi = 96;

  # Home-manager session config.
  services.xserver.desktopManager.session = [{
    name = "home-manager";
    start = ''
      ${pkgs.runtimeShell} $HOME/.hm-xsession &
      waitPID=$!
    '';
  }];

  # Automatic monitor configuration.
  services.autorandr.enable = true;

}
