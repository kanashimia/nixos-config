self: super: let
  colors = super.writeTextFile {
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
in {
  palenight-gtk = super.stdenv.mkDerivation {
    name = "palenight-gtk";

    src = self.unstable.materia-theme.src;

    nativeBuildInputs = with super; [
      sassc
      bc
      inkscape
    ];

    buildInputs = with super; [
      gnome3.gnome-themes-extra
      gdk-pixbuf
      librsvg
    ];

    propagatedUserEnvPkgs = with super; [
      gtk-engine-murrine
    ];

    dontBuild = true;
     
    installPhase = ''
      patchShebangs .
      sed -i install.sh \
      -e "s|if .*which gnome-shell.*;|if true;|" \
      -e "s|CURRENT_GS_VERSION=.*$|CURRENT_GS_VERSION=${super.stdenv.lib.versions.majorMinor super.gnome3.gnome-shell.version}|"
      substituteInPlace change_color.sh --replace "\$HOME/.themes" "$out/share/themes"
      ./change_color.sh -o Palenight ${colors}
    '';

    postInstall = ''
      rm $out/share/themes/*/COPYING
    '';
  };
}
