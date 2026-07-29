{ config, lib, pkgs, ... }: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
    extraDaemonFlags = [ "--no-logs-no-support" ];
  };

  systemd.user.services."tailscale-systray" = {
    description = "Tailscale System Tray";
    after = [ "systemd.service" ];
    wantedBy = [ "sway.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/tailscale systray";
    };
  };

  # systemd.services.tailscaled.serviceConfig.Environment = [ "TS_DEBUG_MTU=1350" ];

  # services.netbird = {
  #   clients.default = {
  #     port = 21820;
  #     interface = "nb0";
  #     name = "netbird";
  #     hardened = false;
  #   };
  # };
}
