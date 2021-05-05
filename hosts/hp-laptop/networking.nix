{
  # Need to make interface use DHCP manually, because systemd.
  networking.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = true;
  
  # iwd + systemd-networkd > NetworkManager.
  networking.useNetworkd = true;
  networking.wireless.iwd.enable = true;
}
