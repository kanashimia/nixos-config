{ config, pkgs, lib, nixosModules, ... }: {
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      foot
      # bemenu # sirula
      # rofi-wayland
      wofi
      # sirula
      j4-dmenu-desktop

      telegram-desktop
      keepassxc
      zathura 
      # qutebrowser-qt6
      chromium
      firefox

      # nheko

      wev
      imv
      vimiv-qt
      libsixel
      mpv

      # wob

      wl-clipboard 
      # sway-contrib.grimshot 
      grim 
      slurp
      wf-recorder
      # swappy
      # mesa-demos
      vulkan-tools 
      # glmark2
      # drm_info

      swaylock
      swayidle

      # waybar

      brightnessctl

      (linkFarm "default-terminal" [ 
        { name = "bin/gnome-terminal"; path = "${pkgs.foot}/bin/foot"; } 
      ])
    ];
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  # xdg.portal.enable = true;
  # services.gnome.gnome-keyring.enable = true;

  # security.wrappers.sway = {
  #   program = "sway-cap";
  #   source = "${pkgs.sway-unwrapped}/bin/sway";
  #   capabilities = "cap_sys_nice+ep";
  #   owner = "root";
  #   group = "root";
  # };

  # security.pam.services.login.enableGnomeKeyring = true;

  # systemd.user.services.polkit-gnome-auth-agent = {
  #   description = "Legacy polkit authentication agent for GNOME";
  #   documentation = [ "man:polkit(8)" ];
  #   partOf = [ "graphical-session.target" ];
  #   after = [ "graphical-session.target" ];
  #   unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
  #   serviceConfig = {
  #     ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  #   };
  #   wantedBy = [ "graphical-session.target" ];
  # };
  
  # systemd.user.targets.sway-session = {
  #   description = "Sway compositor session";
  #   documentation = [ "man:systemd.special(7)" ];
  #   bindsTo = [ "graphical-session.target" "sway.scope" ];
  #   wants = [ "graphical-session-pre.target" ];
  #   after = [ "graphical-session-pre.target" ];
  # };

  # systemd.user.services.wob = {
  #   description = "A lightweight overlay bar for Wayland";
  #   documentation = [ "man:wob(1)" ];
  #   partOf = [ "graphical-session.target" ];
  #   after = [ "graphical-session.target" ];

  #   unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
  #   
  #   serviceConfig = {
  #     StandardInput = "socket";
  #     ExecStart = "${pkgs.wob}/bin/wob";
  #   };

  #   wantedBy = [ "graphical-session.target" ];
  # };

  # systemd.user.sockets.wob = {
  #   socketConfig = {
  #     ListenFIFO = "%t/wob.sock";
  #     SocketMode = 0600;
  #   };

  #   wantedBy = [ "sockets.target" ];
  # };

  environment.variables.BEMENU_OPTS = with config.themes.colors;
    lib.concatStringsSep " " [
      "-p >>=" "-i" "-H 24"
      "--nb ${backgroundDim}" "--nf ${foreground}"
      "--ab ${backgroundDim}" "--af ${foreground}"
      "--fb ${backgroundDim}" "--ff ${foreground}"
      "--tb ${backgroundDim}" "--tf ${cyan}"
      "--hf ${backgroundDim}" "--hb ${blue}"
      "--hp 10"
    ];

  # systemd.services.greetd = {
      # environment.LIBSEAT_BACKEND = "logind";
  #   environment.SEATD_VTBOUND="0";
  # };

  systemd.user.targets.graphical-session = {
      unitConfig = lib.mkForce {};
  };

  # systemd.user.services.sway = {
  # };

  environment.etc = {
    "sway/config".source = ./config;
    # "sway/config.d/nixos.conf".text = lib.mkForce "";
    "sway/config.d/20-start-session.conf".text = ''
      exec 'systemctl import-environment --user DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP'
    '';
  };
  # systemctl --user restart graphical-session.target
  services.greetd = let
    swaySession = pkgs.writeShellScript "sway-session" ''
      exec systemd-cat -t sway -- \
        systemd-run --user --scope --quiet --no-ask-password \
          --slice session -u sway \
          -p BindsTo=graphical-session.target \
          -- sway
    '';
    # systemd-run --user --scope --quiet --no-ask-password -u sway --slice sway /run/current-system/sw/bin/sway
    greetd-sway-gtkgreet = pkgs.writeText "greetd-sway-gtkgreet.conf" ''
      # include /etc/sway/config.d/*

      input * {
          xkb_layout "us(dvorak),ru(ruu)"
          xkb_options "caps:escape,grp_led:num,grp:rctrl_rshift_toggle"
      }
      input type:touchpad {
          tap enable
          dwt disable
          natural_scroll enabled
      }
      exec '${pkgs.greetd.gtkgreet}/bin/gtkgreet -lc ${swaySession}; swaymsg exit'
    '';
  in {
    enable = true;

    # settings.default_session.command = ''
    #   ${pkgs.greetd.greetd}/bin/agreety --cmd ${swaySession}
    # '';

    # settings.default_session.command = ''
    #   sway --config ${greetd-sway-gtkgreet} &> /dev/null
    # '';

    # settings.default_session.command = ''
    #   ${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${swaySession}
    # '';

    vt = 7;
    # settings.terminal.vt = lib.mkForce "none";
    settings.default_session = {
      # command = "${pkgs.kmscon}/bin/kmscon -l -- /bin/sh -l";
      command = swaySession;
      # command = "sway";
      user = "kanashimia";
    };

    # settings.initial_session = {
    #   command = swaySession;
    #   user = "kanashimia";
    # };
  };

  # systemd.services.greetd.serviceConfig = {
  #     RestartSec = 1;
  #     TTYPath = "/dev/tty7";
  #     TTYReset = "yes";
  #     TTYVHangup = "yes";
  #     TTYVTDisallocate = "yes";
  # };

  # environment.sessionVariables.SEATD_VTBOUND = "0";
  # environment.etc."sway/config.d/00-lock-session.conf".text = ''
  #   exec swaylock -c 000000 -u
  # '';

  # environment.etc."sessions/sway.desktop".text = let
  #   swaySession = pkgs.writeShellScript "sway-session" ''
  #     exec systemd-cat -t sway -- \
  #       systemd-run --user --scope --quiet --no-ask-password \
  #       --slice session.slice -p PartOf=graphical-session.target \
  #       -u sway -- sway
  #   '';
  # in ''
  #   [Desktop Entry]
  #   Type=Application
  #   Name=Sway
  #   Exec=${swaySession}
  # '';

  systemd.defaultUnit = "graphical.target";

  # systemd.user.services.sway = {
  #   wantedBy = [ "graphical-session.target" ];
  #   before = [ "graphical-session.target" ];
  #   serviceConfig = {
  #     # Type = "notify";
  #     ExecStart = "${pkgs.sway}/bin/sway --unsupported-gpu";
  #     # NotifyAccess = "exec";
  #   };
  # };
  
  security.pam.services."sway-autologin".text =''
    auth      required  pam_nologin.so
    auth      required  pam_unix.so     try_first_pass nullok

    account   required  pam_nologin.so
    account   required  pam_unix.so

    session   required  pam_env.so conffile=/etc/pam/environment readenv=0
    session   required  pam_unix.so
    -session  optional  ${config.systemd.package}/lib/security/pam_systemd.so type=wayland class=user desktop=sway
    -session  optional  pam_loginuid.so
  '';

  systemd.user.slices."app".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "40%";
  };

  systemd.services.sway = {
    enable = false;
    wantedBy = [ "graphical.target" ];
    before = [ "graphical.target" ];

    wants = [
      # "dbus.socket"
      "systemd-user-sessions.service"
    ];
    after = [
      # "dbus.socket"
      "systemd-user-sessions.service"
      # "getty@tty8.service"
    ];
    # conflicts = [ "getty@tty7.service" ];
    #
    # environment.XDG_SESSION_CLASS = "user";
    # environment.PATH = "${pkgs.sway}/bin";

    # script = ''
    #   PATH=/run/current-system/sw/bin
    #   # exec systemd-run --user --scope --quiet --no-ask-password \
    #   #   --slice=session.slice \
    #   #   -p PartOf=graphical-session.target \
    #   #   -u sway -- sway --unsupported-gpu
    #   exec sway
    # '';

    serviceConfig = {
      # UnsetEnvironment = [ "WAYLAND_DISPLAY" "DISPLAY" "SWAYSOCK" "XDG_CURRENT_DESKTOP" ];
      # Environment = "LIBSEAT_BACKEND=logind";
      # ExecStart = "/run/current-system/sw/bin/sway --unsupported-gpu";
      ExecStart = "systemd-run --user --scope --quiet --no-ask-password -u sway --slice sway /run/current-system/sw/bin/sway";
      # ExecStart = "${config.systemd.package}/bin/systemd-run --user --scope --quiet --no-ask-password --slice session.slice -u sway -- ${pkgs.sway}/bin/sway --unsupported-gpu";
      # ExecStart = "${config.systemd.package}/bin/systemctl --user --wait start sway";
# ${pkgs.runtimeShell} -l
#

      # TimeoutStartSec = 30;
      # WatchdogSec = 10;

      # PAMName = "sway-autologin";
      PAMName = "login";
      # PAMName = "login";
      User = "kanashimia";
      WorkingDirectory = "~";

      TTYPath = "/dev/tty7";
      # TTYReset = "yes";
      # TTYVHangup = "yes";
      # TTYVTDisallocate = "yes";

      StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";

      UtmpIdentifier = "tty7";
      UtmpMode = "user";
     
      Restart = "always";
      RestartSec = 1;

      # Slice = "session.slice";
    };

    restartIfChanged = false;
  };

  # systemd.user.services.sway = let bin = "/run/current-system/sw/bin"; in {
  #     enable = true;
  #     unitConfig = {
  #       Wants = [ "default.target" ];
  #       After = [ "default.target" ];
  #       BindsTo = [ "default.target" ];
  #     };

  #    wantedBy = [ "default.target" ];

  #     serviceConfig = {
  #       ExecStart = "${bin}/dbus-launch ${bin}/sway";

  #       # TTYPath = "/dev/tty7";
  #       # TTYReset = "yes";
  #       # TTYVHangup = "yes";
  #       # TTYVTDisallocate = "yes";
  #       
  #       # PAMName = "login";
  #       # User = "kanashimia";

  #       # StandartInput = "tty-fail";
  #     };
  # };

  services.getty.extraArgs = [ "--nonewline" ];
}
