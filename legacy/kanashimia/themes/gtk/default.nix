{ pkgs, colors, ... }:

let
my-colors = pkgs.writeTextFile {
  name = "colors";
  text = ''
    BG=292D3E
    FG=d5d5e1
    MATERIA_VIEW=292D3E
    MATERIA_SURFACE=303348
    HDR_BG=202331
    HDR_FG=A6ACCD
    SEL_BG=82aaff
  '';
};

palenight-gtk = pkgs.materia-theme.overrideAttrs (old: {
  nativeBuildInputs = with pkgs; [ inkscape bc sassc optipng ];
  configurePhase = ''
    patchShebangs .
    substituteInPlace render-assets.sh \
      --replace "rendersvg" "resvg"
    substituteInPlace src/chrome/render-asset.sh \
      --replace "rendersvg" "resvg"
    substituteInPlace src/gtk/render-asset.sh \
      --replace "rendersvg" "resvg"
    substituteInPlace src/gtk-2.0/render-asset.sh \
      --replace "rendersvg" "resvg"
    ./change_color.sh -t $out/share/themes -o Palenight ${my-colors}
  '';
});
in
{
  fonts.fontconfig.defaultFonts.emoji = [
    "Twemoji Color"
  ];

  fonts.fonts = with pkgs; [
    twemoji-color-font
    dejavu_fonts
    gyre-fonts
    liberation_ttf
    xorg.fontmiscmisc
    xorg.fontcursormisc
    unifont
  ];
  fonts.enableDefaultFonts = false;
  
  environment.systemPackages = with pkgs; [
    pkgs.papirus-icon-theme palenight-gtk libsForQt5.qtstyleplugins
  ];

  environment.etc."xdg/gtk-2.0/gtkrc".text = ''
    gtk-theme-name="Palenight"
    gtk-icon-theme-name="Papirus-Dark"
  '';
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Palenight
    gtk-icon-theme-name=Papirus-Dark
  '';
  qt5 = {
    enable = true;
    style = "gtk2";
    platformTheme = "gtk2";
  };
}
