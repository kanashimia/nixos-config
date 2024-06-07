{ pkgs, ... }: {
  imports = [
    ./vpn.nix
    ./ssh.nix
    ./terraria.nix
    ./caddy.nix
    # ./openobserve.nix
    ./stalwart-mail.nix
  ];

  boot.initrd.availableKernelModules = [
    "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio"
    "virtio_balloon" "virtio_console" "virtio_rng"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  services.journald.extraConfig = ''
    SystemMaxUse=100M
  '';

  networking.firewall.logRefusedConnections = false;

  systemd.network.networks."40-wired" = {
    name = "en*";
    networkConfig = {
      DHCP = "yes";
      Address = [ "2a01:4f8:1c1c:260a::/64" ];
      Gateway = [ "fe80::1" ];
    };
    dhcpV4Config.UseDNS = false;
    dhcpV6Config.UseDNS = false;
    ipv6AcceptRAConfig.UseDNS = false;
  };

  environment.systemPackages = [ pkgs.htop ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "23.05";
}
