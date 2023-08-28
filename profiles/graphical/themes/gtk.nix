{ pkgs, ... }: let
  iconTheme = "Papirus";
  gtk2Theme = "Adwaita";
  gtk3Theme = "adw-gtk3";
  gtkFontName = "DejaVu Sans 10";
  dark = true;
in {
  environment.etc = {
    # "xdg/gtk-2.0/gtkrc".text = ''
    #   gtk-theme-name = "${gtk2Theme}"
    #   gtk-icon-theme-name = "${iconTheme}"
    #   gtk-font-name = "${gtkFontName}"
    # '';
    "xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme = ${toString dark}
      gtk-theme-name = ${gtk3Theme}
      gtk-icon-theme-name = ${iconTheme}
      gtk-font-name = ${gtkFontName}
    '';
    "xdg/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme = ${toString dark}
      gtk-icon-theme-name = ${iconTheme}
      gtk-font-name = ${gtkFontName}
      gtk-cursor-theme-name = Adwaita
      gtk-cursor-theme-size = 24
    '';
    "dconf/db".source = pkgs.runCommandLocal "dconf-db" {} ''
      mkdir -p $out/local.d
      cat <<- EOF > $out/local.d/10-theme
        [org/gnome/desktop/interface]
        color-scheme='prefer-${if dark then "dark" else "light"}'
        gtk-theme='${gtk3Theme}'
        icon-theme='${iconTheme}'
        font-name='${gtkFontName}'
      EOF
      ${pkgs.dconf}/bin/dconf compile $out/local $out/local.d
    '';
    "dconf/profile/user".text = ''
      user-db:user
      system-db:local
    '';
  };

  # environment.sessionVariables.GTK_THEME = theme;
  environment.sessionVariables = {
    # QT_STYLE_OVERRIDE = "Adwaita-dark";
    QT_QPA_PLATFORMTHEME = "gtk3";
    # KRITA_NO_STYLE_OVERRIDE = "1";
  };

  environment.systemPackages = with pkgs; [
    # libsForQt5.qtstyleplugin-kvantum
    # libsForQt5.qtstyleplugins
    # qt5ct
    qgnomeplatform
    adwaita-qt
    gnome-themes-extra
    papirus-icon-theme
    adw-gtk3
  ];


  # gtk.iconCache.enable = true;
}
