{ pkgs, ... }:

{
  fonts.fontconfig.defaultFonts.emoji = [
    "Twitter Color Emoji"
  ];

  fonts.fonts = with pkgs; [
    twemoji-color-font
    dejavu_fonts
    gyre-fonts
    liberation_ttf
    xorg.fontmiscmisc
    xorg.fontcursormisc
    unifont
    noto-fonts-cjk
    fira-code
  ];

  fonts.enableDefaultFonts = false;
}
