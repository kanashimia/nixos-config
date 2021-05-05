{
  # Need to make interface use DHCP manually, because systemd.
  # networking.useDHCP = false;
  #networking.interfaces.enp2s0.useDHCP = true;
  
  # systemd master race.
  networking.useNetworkd = true;
}
