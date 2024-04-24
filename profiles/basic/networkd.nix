{ config, lib, ... }: {
  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  services.timesyncd.servers = [
    "time.cloudflare.com"
    "ntp.time.in.ua"
    "216.239.35.4" # time2.google.com
    "216.239.35.12" # time4.google.com
  ];

  services.resolved.extraConfig = lib.generators.toKeyValue {} {
    DNSSEC = "allow-downgrade";
    DNSOverTLS = "yes";
  };

  systemd.network.networks = {
    "90-dhcp-ether" = {
      matchConfig = {
        Type = "ether";
      };
      networkConfig = {
        DHCP = "yes";
      };
      dhcpV4Config = {
        UseDNS = false;
        RouteMetric = 1024;
      };
    };
    "90-dhcp-wlan" = {
      matchConfig = {
        Type = "wlan";
      };
      networkConfig = {
        DHCP = "yes";
        IgnoreCarrierLoss = "3s";
      };
      dhcpV4Config = {
        UseDNS = false;
        RouteMetric = 2048;
      };
    };
  };

  systemd.network.wait-online.anyInterface = true;

  systemd.targets."network-online".wantedBy = lib.mkForce [];

  services.nscd.enableNsncd = true;
}
