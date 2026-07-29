{ config, pkgs, lib, ... }: let
  tty = "tty1";
in {
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    wrapperFeatures.base = false;
  };

  environment.systemPackages = with pkgs; [
    foot
    wofi
    # j4-dmenu-desktop

    telegram-desktop
    keepassxc
    zathura
    chromium
    thunderbird
    firefox-devedition
    # librewolf
    # vivaldi
    zed-editor-fhs

    wev
    imv
    libsixel
    mpv-unwrapped

    wl-clipboard
    grim
    slurp
    wf-recorder
    wl-screenrec
    vulkan-tools
    mesa-demos
    wayland-utils
    libva-utils

    swaylock
    swayidle

    brightnessctl

    (linkFarm "xdg-terminal-exec" [
      { name = "bin/xdg-terminal-exec"; path = lib.getExe pkgs.foot; }
    ])
  ];

  environment.sessionVariables = {
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  xdg.portal.enable = true;
  xdg.portal.xdgOpenUsePortal = true;
  xdg.portal.extraPortals = with pkgs; [ 
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];

  xdg.portal.wlr.enable = lib.mkForce false;

  environment.etc = {
    "sway/config".source = ./config;
    "sway/config.d/nixos.conf".text = lib.mkForce "";
    "sway/config.d/20-start-session.conf".text = ''
      exec 'systemctl import-environment --user PATH DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP; systemctl --user start sway.target'
    '';
  };

  systemd.user.targets.sway = {
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  systemd.defaultUnit = "graphical.target";

  services.greetd = let
    swaySession = pkgs.writeShellScript "sway-session" ''
      export XDG_CURRENT_DESKTOP=sway
      # exec systemd-cat -t sway -- \
      #   systemd-run --user --scope --quiet --no-ask-password \
      #     --slice session -u sway b\
      #     -p PartOf=sway.target \
      #     -- sway
      exec systemd-cat -t sway sway
    '';
    swayLogin = pkgs.writeText "sway-login-config" ''
      # `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
      exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -c ${swaySession}; swaymsg exit"

      input type:keyboard {
        xkb_layout "us(dvorak),ru,ua"
        xkb_options "caps:escape,grp_led:num,grp:rctrl_rshift_toggle,compose:menu"
      }

      output * background #242424 solid_color

      bindsym Mod4+shift+q swaymsg exit

      bindsym Mod4+shift+e exec swaynag \
        -t warning \
        -m 'What do you want to do?' \
        -b 'Poweroff' 'systemctl poweroff' \
        -b 'Reboot' 'systemctl reboot'
    '';
  in {
    enable = false;
    restart = true;
    # settings.initial_session = {
    #   command = swaySession;
    #   user = "kanashimia";
    # };
    settings.default_session = {
      # command = swaySession;
      # command = "${pkgs.greetd}/bin/agreety --cmd ${swaySession}";
      # user = "kanashimia";
      # command = "sway";
      # command = "systemd-cat -t sway -- sway --config ${swayLogin}";
      # command = "${pkgs.greetd.greetd}/bin/agreety --cmd ${swaySession}";
      # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd ${swaySession}";
      # command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.regreet}/bin/regreet";
      # user = "greeter";
    };
    # restart = true;
  };

  # programs.regreet.enable = true;

  security.pam.services."autologin" = {
    startSession = true;
    allowNullPassword = true;
    showMotd = true;
    lastlog.enable = true;
  };

  systemd.services."autovt@${tty}".enable = false;

  systemd.user.services."foot-server" = {
    wantedBy = [ "sway.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "exec";
      ExecStart = "${lib.getExe pkgs.foot} --server";
    };
  };
  systemd.user.services."waybar" = {
    wantedBy = [ "sway.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "exec";
      ExecStart = lib.getExe pkgs.waybar;
    };
  };
  systemd.user.services."swayidle" = {
    wantedBy = [ "sway.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "exec";
      ExecStart = "${lib.getExe pkgs.swayidle} idlehint 60";
    };
  };

# [Unit]
# Description=Lock Sway screen before sleep
# Before=sleep.target

# [Service]
# Type=forking
# Environment=WAYLAND_DISPLAY=wayland-0
# ExecStart=/usr/bin/swaylock -f -c 000000

# [Install]
# WantedBy=sleep.target
  systemd.services.sway-al = let
    swaySession = pkgs.writeShellScript "sway-session" ''
      export XDG_CURRENT_DESKTOP=sway
      exec systemd-cat -t sway /run/current-system/sw/bin/sway
    '';
      # exec systemd-cat -t sway -- \
      #   systemd-run --user --scope --quiet --no-ask-password \
      #     --slice session -u sway b\
      #     -p PartOf=sway.target \
      #     -- sway
  in {
    enable = true;
    description = "Autologin";
    after = [ "systemd-user-sessions.service" "plymouth-quit-wait.service" "getty@${tty}.service" ];
    conflicts = [ "getty@${tty}.service" ];
    aliases = [ "display-manager.service" ];

    serviceConfig = {
      Type = "exec";
      ExecStart = "${lib.getExe pkgs.autologin} kanashimia ${swaySession}";

      TimeoutStopSec = "30s";
      KeyringMode = "shared";

      TTYPath = "/dev/${tty}";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";

      IgnoreSIGPIPE = "no";
      SendSIGHUP = "yes";

      # StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";

      UtmpIdentifier = tty;
      UtmpMode = "user";

      Restart = "always";
      RestartSec = 1;
    };
    unitConfig = {
      StartLimitBurst = 5;
      StartLimitIntervalSec = 30;
    };
    restartIfChanged = false;
  };

  # systemd.slices."-".sliceConfig = {
  #   ManagedOOMSwap = "kill";
  # };

  # systemd.user.slices."-".sliceConfig = {
  #   ManagedOOMMemoryPressure = "kill";
  #   # ManagedOOMMemoryPressureLimit = "40%";
  # };

  # systemd.user.slices."app".sliceConfig = {
  #   ManagedOOMMemoryPressure = "kill";
  #   ManagedOOMMemoryPressureLimit = "40%";
  # };
}
