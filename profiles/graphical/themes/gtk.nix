{ lib, pkgs, ... }: let
  iconTheme = "Papirus";
  gtk3Theme = "adw-gtk3";
  gtkFontName = "DejaVu Sans 10";
  dark = true;
in {
  environment.etc = {
    "xdg/gtk-3.0/settings.ini".text = lib.generators.toINI {} {
      Settings = {
        gtk-application-prefer-dark-theme = dark;
        # gtk-theme-name = gtk3Theme;
        # gtk-icon-theme-name = iconTheme;
        # gtk-font-name = gtkFontName;
      };
    };
    "xdg/gtk-4.0/settings.ini".text = lib.generators.toINI {} {
      Settings = {
        # gtk-application-prefer-dark-theme = dark;
        # gtk-icon-theme-name = iconTheme;
        # gtk-font-name = gtkFontName;
        # gtk-cursor-theme-name = "Adwaita";
        # gtk-cursor-theme-size = 24;
      };
    };
    "dconf/db".source = pkgs.runCommandLocal "dconf-db" {
      theme = lib.generators.toINI {
        mkKeyValue = k: v: "${k}='${lib.generators.mkValueStringDefault {} v}'";
      } {
        "org/gnome/desktop/interface" = {
          color-scheme = if dark then "prefer-dark" else "prefer-light";
          gtk-theme = gtk3Theme;
          icon-theme = iconTheme;
          font-name = gtkFontName;
          # cursor-theme = "Adwaita";
          # cursor-size = 24;
        };
      };
    } ''
      mkdir -p $out/local.d
      echo -n "$theme" > $out/local.d/10-theme
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
