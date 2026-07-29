{ config, lib, ... }: {
  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  networking.nftables.enable = true;

  # This gives me PTSD, I suggest you all keep at least two good IPs here just in case.
  services.timesyncd.servers = [
    "time.cloudflare.com"
    "pool.ntp.org"
    "pool.time.in.ua"
    "216.239.35.4" # time2.google.com
    "216.239.35.12" # time4.google.com
  ];

  networking.nameservers = [
    "1.1.1.1#cloudflare-dns.com"
  ];

  services.resolved.settings.Resolve = {
    DNSSEC = true; # Maybe some time in the future DNSSEC will be usable, that time is right now.
    DNSOverTLS = true;
    LLMNR = false;
    # MulticastDNS = true;
  };

  systemd.network.networks = let
    defNetworkConf = match: metric: {
      name = match;
      networkConfig = {
        DHCP = "yes";
        IgnoreCarrierLoss = "3s";
        # MulticastDNS = true;
        # MulticastDNS = "resolve";
      };
      dhcpV4Config = { UseDNS = false; RouteMetric = metric; };
      dhcpV6Config = { UseDNS = false; };
      ipv6AcceptRAConfig = { UseDNS = false; RouteMetric = metric; };
    };
  in {
    "90-dhcp-ether" = defNetworkConf "en*" 1024;
    "90-dhcp-wlan" = defNetworkConf "wl*" 2048;
  };

  systemd.network.wait-online.anyInterface = true;
  systemd.network.wait-online.enable = false;

  systemd.targets."network-online".wantedBy = lib.mkForce [];
}
