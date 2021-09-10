{ config, ... }:

{
  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network.networks = let
    networkConfig = {
      DHCP = "yes";
      DNSSEC = "yes";
      DNSOverTLS = "yes";
      DNS = [ "1.1.1.1" "8.8.8.8" "1.0.0.1" "8.8.4.4" ];
      LLMNR = "no";
    };
  in {
    "40-wired" = {
      name = "en*";
      inherit networkConfig;
      dhcpV4Config.RouteMetric = 1024; # Better be explicit
    };
    "40-wireless" = {
      name = "wl*";
      inherit networkConfig;
      dhcpV4Config.RouteMetric = 2048; # Prefer wired
    };
  };

  # Wait for any interface to become avaible, not for all
  systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
    "" "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  ];
}
