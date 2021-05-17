{
  # networkd requires manual DHCP configuration
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;
  
  # systemd master race
  networking.useNetworkd = true;
}
