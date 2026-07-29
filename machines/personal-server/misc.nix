{ pkgs, config, lib, ... }: {
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

  environment.memoryAllocator.provider = "mimalloc";

  # systemd.network.networks."90-wired" = {
  #   name = "en*";
  #   networkConfig = {
  #     DHCP = "yes";
  #     # Address = [ "2a01:4f8:1c1c:260a::1/64" ];
  #     # Gateway = [ "fe80::1" ];
  #   };
  #   dhcpV4Config.UseDNS = false;
  #   dhcpV6Config.UseDNS = false;
  #   ipv6AcceptRAConfig.UseDNS = false;
  # };

  /* systemd.services."hetzner-network-gen" = {
    enable = true;

    conflicts = [ "shutdown.target" ];
    # tailscale has skill issues
    before = [ "shutdown.target" "tailscaled.service" "headscale.service" ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment.PATH = lib.mkForce "${pkgs.iproute2}/bin";

    serviceConfig = {
      ExecStart = [
        (pkgs.writeShellScript "hetzner-network-gen.sh"
          (builtins.readFile ./hetzner-network-gen.sh))
        "${config.systemd.package}/bin/networkctl reload"
      ];
      Type = "oneshot";
    };
  }; */

  systemd.services."hetzner-network-gen" = {
    enable = true;

    conflicts = [ "shutdown.target" ];
    before = [
      # "sysinit.target"
       "systemd-firstboot.service" "shutdown.target"
      # "tailscaled.service" "headscale.service"
    ];
    after = [ "systemd-imdsd.socket" "network-online.target" "systemd-imds-import.service" ];
    wants = [ "systemd-imdsd.socket" "network-online.target" ];

    wantedBy = [ "multi-user.target" ];

    environment.PATH = lib.mkForce "${config.systemd.package}/lib/systemd";

    # unitConfig = {
    #   DefaultDependencies = false;
    # };

    serviceConfig = {
      ExecStart = [
        (pkgs.writeShellScript "hetzner-network-gen.sh"
          (builtins.readFile ./hetzner-network-gen.sh))
        "${config.systemd.package}/bin/networkctl reload"
      ];
      Type = "oneshot";
      TimeoutStartSec = "30s";
    };
  };

  boot.kernelParams = [
    "systemd.imds=on"
    # "systemd.imds.vendor=hetzner-cloud"
    # "systemd.imds.data_url=http://169.254.169.254/hetzner/v1/metadata"
    # "systemd.imds.address_ipv4=169.254.169.254"
    # "systemd.imds.key_hostname=/hostname"
    # "systemd.imds.key_region=/region"
    # "systemd.imds.key_zone=/availability-zone"
    # "systemd.imds.key_ipv4_public=/public-ipv4"
    # "systemd.imds.key_ssh_key=/public-keys/0"
    # "systemd.imds.key_userdata=/userdata"
  ];

  # services.cloud-init = {
  #   enable = false;
  #   network.enable = true;
  #   settings = {
  #     datasource_list = [ "Hetzner" "None" ];
  #   };
  # };

  environment.systemPackages = [ pkgs.htop ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "23.05";
}
