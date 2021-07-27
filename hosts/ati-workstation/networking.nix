{
  networking = {
    # Need to make interface use DHCP manually, because systemd.
    useDHCP = false;
    # interfaces.enp2s0 = {
    #   useDHCP = true;
      # dhcpV4Config.UseDNS = false;
      # dhcpV6Config.UseDNS = false;
      # dns = [ "1.1.1.1" ];
    # };

    # systemd master race.
    useNetworkd = true;
    # nameservers = [ "1.1.1.1" ];
  };
  systemd.network.enable = true;
  systemd.network.networks."10-enp2s0" = {
    name = "enp2s0";
    enable = true;
    DHCP = "yes";
    dns = [ "1.1.1.1" "1.0.0.1" ];
    networkConfig = {
      DNSSEC = "yes";
      DNSOverTLS = "yes";
    };
  };
  
  # services.resolved = {
    # domains = [ "~." ];
    # extraConfig = ''
    #   DNS=9.9.9.9#dns.quad9.net
    #   DNSOverTLS=yes
    # '';
    # dnssec = "true";
  # };
  # systemd.services.systemd-networkd-wait-online.enable = false;
}
