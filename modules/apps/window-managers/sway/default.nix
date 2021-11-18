{ config, pkgs, lib, nixosModules, ... }: let
  runSession = name: pkgs.writeShellScript "start-${name}-session" ''
    exec systemd-cat -t '${name}' -- \
      systemd-run --user --scope --quiet --no-ask-password \
      --slice session.slice -p Wants=graphical-session.target \
      -u '${name}' -- '${name}'
  '';
in {
  programs.sway = {
    enable = true;
    # wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      foot
      bemenu
      j4-dmenu-desktop

      kotatogram-desktop
      keepassxc

      qutebrowser

      wev
      imv

      wofi

      wl-clipboard slurp grim swappy
    ];
  };

  imports = with nixosModules; [ apps.terminals.foot ];

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
  #   gtk-engine-murrine
  #   gtk_engines
  #   gsettings-desktop-schemas
  #   # lxappearance
  #   # materia-theme
    gnome3.defaultIconTheme
  #   gnome.gnome-themes-extra
  #   gnome.adwaita-icon-theme
  ];

  xdg.portal.enable = true;

  # xdg.portal.gtkUsePortal = true;
  # xdg.portal.extraPortals = with pkgs; [
  #   xdg-desktop-portal-gtk
  # ];
  gtk.iconCache.enable = true;

  environment.etc."sway/config".source = ./config;

  environment.variables.BEMENU_OPTS = with config.themes.colors;
    lib.concatStringsSep " " [
      "-p >>=" "-i" "-l 10"
      "--nb ${background}" "--nf ${foreground}"
      "--tb ${background}" "--tf ${cyan}"
      "--hf ${background}" "--hb ${blue}"
    ];

  services.greetd = {
    enable = true;
    settings.default_session.command = ''
      ${pkgs.greetd.greetd}/bin/agreety --cmd sway
    '';
  };

  services.getty.extraArgs = [ "--nonewline" ];
}
