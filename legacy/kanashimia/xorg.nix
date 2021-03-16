{ pkgs, ...}:

{
  # General xorg config.
  services.xserver = {
    enable = true;
  };

  # Force dpi to const value
  services.xserver.dpi = 96;
  fonts.fontconfig.dpi = 96;

  # Automatic monitor configuration.
  services.autorandr.enable = true;
}
