{ config, pkgs, lib, ... }: {
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    enableRealtime = false;
    extraPackages = with pkgs; [
      foot
      wofi
      j4-dmenu-desktop

      telegram-desktop
      keepassxc
      zathura 
      chromium
      firefox

      wev
      imv
      vimiv-qt
      libsixel
      mpv

      wl-clipboard 
      grim 
      slurp
      wf-recorder
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
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  environment.etc = {
    "sway/config".source = ./config;
    "sway/config.d/nixos.conf".text = lib.mkForce "";
    "sway/config.d/20-start-session.conf".text = ''
      exec 'systemctl import-environment --user DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP; systemctl --user start sway.target'
    '';
  };

  systemd.user.targets.sway = {
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  services.greetd = let
    swaySession = pkgs.writeShellScript "sway-session" ''
      exec systemd-cat -t sway -- \
        systemd-run --user --scope --quiet --no-ask-password \
          --slice session -u sway \
          -p PartOf=sway.target \
          -- sway
    '';
  in {
    enable = true;
    vt = 7;
    settings.default_session = {
      command = swaySession;
      user = "kanashimia";
    };
  };

  systemd.user.slices."app".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "40%";
  };
}
