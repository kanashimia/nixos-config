{ config, lib, ... }: {
  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  # This gives me PTSD, I suggest you all keep at least two good IPs here just in case.
  services.timesyncd.servers = [
    "time.cloudflare.com"
    "ntp.time.in.ua"
    "216.239.35.4" # time2.google.com
    "216.239.35.12" # time4.google.com
  ];

  services.resolved.extraConfig = lib.generators.toKeyValue {} {
    DNSSEC = false; # Maybe some time in the future DNSSEC will be usable.
    DNSOverTLS = true;
    DNS = lib.concatStringsSep " " [
      "9.9.9.9#dns9.quad9.net"
      "1.1.1.1#cloudflare-dns.com"
      "8.8.8.8#dns.google"

      "149.112.112.112#dns.quad9.net"
      "1.0.0.1#cloudflare-dns.com"
      "8.8.4.4#dns.google"

      "2620:fe::fe#dns.quad9.net"
      "2606:4700:4700::1111#cloudflare-dns.com"
      "2001:4860:4860::8888#dns.google"

      "2620:fe::9#dns9.quad9.net"
      "2606:4700:4700::1001#cloudflare-dns.com"
      "2001:4860:4860::8844#dns.google"
    ];
  };

  systemd.network.networks = let 
    dhcpRAConf = metric: {
      UseDNS = false;
      RouteMetric = metric;
    };
    defNetworkConf = match: metric: {
      name = match;
      networkConfig = {
        DHCP = "yes";
        IgnoreCarrierLoss = "3s";
      };
      dhcpV4Config = dhcpRAConf metric;
      dhcpV6Config = dhcpRAConf metric;
      ipv6AcceptRAConfig = dhcpRAConf metric;
    };
  in {
    "90-dhcp-ether" = defNetworkConf "en*" 1024;
    "90-dhcp-wlan" = defNetworkConf "wl*" 2048;
  };

  systemd.network.wait-online.anyInterface = true;

  systemd.targets."network-online".wantedBy = lib.mkForce [];
}
