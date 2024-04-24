{ config, pkgs, lib, ... }: let
  tty = "tty1";
in {
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = false;
    wrapperFeatures.base = false;
    extraPackages = with pkgs; [
      foot
      wofi
      # j4-dmenu-desktop

      telegram-desktop
      keepassxc
      zathura 
      chromium-xdg

      wev
      imv
      libsixel
      mpv

      wl-clipboard 
      grim 
      slurp
      wf-recorder
      wl-screenrec
      vulkan-tools 

      swaylock
      swayidle

      brightnessctl

      (linkFarm "default-terminal" [ 
        { name = "bin/gnome-terminal"; path = "${pkgs.foot}/bin/foot"; } 
      ])
    ];
  };

  xdg.portal.enable = true;
  xdg.portal.xdgOpenUsePortal = true;
  xdg.portal.extraPortals = with pkgs; [ 
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];

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

      output * background #303030 solid_color

      bindsym Mod4+shift+e exec swaynag \
        -t warning \
        -m 'What do you want to do?' \
        -b 'Poweroff' 'systemctl poweroff' \
        -b 'Reboot' 'systemctl reboot'
    '';
  in {
    enable = true;
    vt = 1;
    settings.default_session = {
      command = swaySession;
      user = "kanashimia";
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

  systemd.services."autovt@${tty}".enable = false;

  /*

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
  systemd.user.services.sway = {

# Activate using a systemd socket
# Requires = weston.socket
# After = weston.socket

before = [ "graphical-session.target" ];
wantedBy = [ "graphical-session.target" ];

  serviceConfig = {
      UnsetEnvironment = [ "WAYLAND_DISPLAY" "DISPLAY" "SWAYSOCK" "XDG_CURRENT_DESKTOP" ];
# Type=notify
Type = "simple";
TimeoutStartSec = 60;
WatchdogSec=20;
# Defaults to journal
#StandardOutput=journal
StandardError="journal";

# add a ~/.config/weston.ini and weston will pick-it up
# ExecStart=/usr/bin/weston --modules=systemd-notify.so
      ExecStart = "/run/current-system/sw/bin/sway";
      };
};



  systemd.services.sway = {
    enable = true;
    wantedBy = [ "graphical.target" ];

    # wants = [ "systemd-user-sessions.service" ];
    after = [ "systemd-user-sessions.service" "getty@${tty}.service" ];
    conflicts = [ "getty@${tty}.service" ];

    # script = ''
    #   PATH=/run/current-system/sw/bin
    #   # exec systemd-run --user --scope --quiet --no-ask-password \
    #   #   --slice=session.slice \
    #   #   -p PartOf=graphical-session.target \
    #   #   -u sway -- sway --unsupported-gpu
    #   exec sway
    # '';

    environment = {
      XDG_CURRENT_DESKTOP = "sway";
    };

    serviceConfig = {
      Type = "simple";
      # UnsetEnvironment = [ "WAYLAND_DISPLAY" "DISPLAY" "SWAYSOCK" "XDG_CURRENT_DESKTOP" ];
      Environment = [ "XDG_CURRENT_DESKTOP=sway" ];
      # ExecStart = "/run/current-system/sw/bin/sway --unsupported-gpu";
      # ExecStart = "systemd-run --user --scope --quiet --no-ask-password -u sway --slice sway /run/current-system/sw/bin/sway";
      # ExecStart = "/run/current-system/sw/bin/dbus-run-session /run/current-system/sw/bin/sway";
      ExecStart = "/run/current-system/sw/bin/sway";
      # Type = "exec";
      # ExecStart = "${pkgs.dbus}/bin/dbus-launch /run/current-system/sw/bin/sway";
      ExecStopPost = "systemctl --user stop sway.target";
      # ExecStart = "${pkgs.gnome.mutter}/bin/mutter --wayland -- ${pkgs.foot}/bin/foot";
      # ExecStart = "${config.systemd.package}/bin/systemd-run --user --scope --quiet --no-ask-password --slice session.slice -u sway -- ${pkgs.sway}/bin/sway --unsupported-gpu";
      # ExecStart = "${config.systemd.package}/bin/systemctl --user --wait start sway";

      # TimeoutStartSec = 30;
      # WatchdogSec = 10;

      PAMName = "login";
      # PAMName = "sway-autologin";
      User = "kanashimia";
      Group = "users";
      WorkingDirectory = "~";

      TTYPath = "/dev/${tty}";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";

      StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";

      UtmpIdentifier = tty;
      UtmpMode = "user";

      Restart = "always";
      RestartSec = 1;
    };


    restartIfChanged = false;
  };
  */

  systemd.user.slices."app".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "40%";
  };
} 
