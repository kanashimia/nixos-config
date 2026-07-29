{ pkgs, lib, config, inputs, ... }: let
  wrapBinScript = pkg: script: pkgs.symlinkJoin {
    inherit (pkg) pname version meta;
    paths = [
      (pkgs.writeShellScriptBin (pkg.meta.mainProgram) (script + ''
        exec ${lib.getExe pkg} "$@"
      ''))
      pkg
    ];
    PKG = pkg;
    postBuild = ''
      for EXEC in $out/bin/*; do
        for FILE in $out/share/applications/*; do
          sed -i "s#$PKG/bin/$(basename "$EXEC")#$EXEC#" "$FILE"
        done
      done
    '';
  };
in {
  environment.etc."firejail/chromium-common.local".text = ''
    blacklist /etc/ld-nix.so.preload
    private-etc xdg
  '';

  environment.etc."firejail/firefox-common.local".text = ''
    blacklist /etc/ld-nix.so.preload
  '';

  environment.etc."firejail/globals.local".text = ''
    dbus-user.talk org.freedesktop.portal.Desktop
  '';
  # dbus-user.talk org.kde.StatusNotifierWatcher
  # dbus-user.own org.kde.*

  environment.etc."firejail/firejail.config".text = ''
    quiet-by-default yes
    allow-tray yes
  '';

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      vivaldi = {
        executable = lib.getExe pkgs.vivaldi;
        profile = "${pkgs.firejail}/etc/firejail/vivaldi.profile";
        desktop = "${pkgs.vivaldi}/share/applications/vivaldi-stable.desktop";
      };
      firefox-devedition = {
        executable = lib.getExe pkgs.firefox-devedition;
        profile = "${pkgs.firejail}/etc/firejail/firefox-developer-edition.profile";
        desktop = "${pkgs.firefox-devedition}/share/applications/firefox-devedition.desktop";
      };
      Telegram = {
        executable = lib.getExe pkgs.telegram-desktop;
        profile = "${pkgs.firejail}/etc/firejail/telegram.profile";
        desktop = "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop";
      };
      thunderbird = {
        executable = lib.getExe pkgs.thunderbird;
        profile = "${pkgs.firejail}/etc/firejail/thunderbird-wayland.profile";
        desktop = "${pkgs.thunderbird}/share/applications/thunderbird.desktop";
      };
    };
  };

  nixpkgs.overlays = [ (final: prev: {
    firejail = prev.firejail.overrideAttrs (old: {
      configureFlags = old.configureFlags ++ [
        "--disable-globalcfg"
      ];
      postPatch = ''
        substituteInPlace src/firejail/checkcfg.c \
          --replace-fail 'SYSCONFDIR "/firejail.config"' '"/etc/firejail/firejail.config"'
      '';
    });
    # vivaldi = wrapBinScript prev.vivaldi ''
    #   unset LD_PRELOAD
    # '';
  }) ];
}
