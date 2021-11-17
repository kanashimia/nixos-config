{ config, lib, ... }: {
  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  services.resolved.extraConfig = ''
    DNSSEC=yes
    DNSOverTLS=yes
  '';

  systemd.network.networks = lib.mapAttrs (_: v:
    lib.recursiveUpdate v {
      networkConfig.DHCP = "yes";
      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
    }
  ) {
    "99-dhcp-wired" = {
      name = "en*";
      dhcpV4Config.RouteMetric = 1024;
    };
    "99-dhcp-wireless" = {
      name = "wl*";
      dhcpV4Config.RouteMetric = 2048; # Prefer wired connection.
    };
  };

  # Wait for any interface to become available, not for all.
  systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
    "" "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  ];
}
