{ pkgs, stdenv, ... }:

let
colors = pkgs.writeTextFile {
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

palenight-gtk = pkgs.stdenv.mkDerivation {
  name = "palenight-gtk";

  src = pkgs.unstable.materia-theme.src;

  nativeBuildInputs = with pkgs; [
    sassc
    bc
    inkscape
  ];

  buildInputs = with pkgs; [
    gnome3.gnome-themes-extra
    gdk-pixbuf
    librsvg
  ];

  propagatedUserEnvPkgs = with pkgs; [
    gtk-engine-murrine
  ];

  dontBuild = true;
   
  installPhase = ''
    patchShebangs .
    sed -i install.sh \
    -e "s|if .*which gnome-shell.*;|if true;|" \
    -e "s|CURRENT_GS_VERSION=.*$|CURRENT_GS_VERSION=${pkgs.stdenv.lib.versions.majorMinor pkgs.gnome3.gnome-shell.version}|"
    substituteInPlace change_color.sh --replace "\$HOME/.themes" "$out/share/themes"
    ./change_color.sh -o Palenight ${colors}
  '';

  postInstall = ''
    rm $out/share/themes/*/COPYING
  '';
};

in
{
  gtk = {
    enable = true;
    theme = {
      package = palenight-gtk;
      name = "Palenight";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };
}
