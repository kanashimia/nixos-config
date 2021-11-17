{ nixosModules, config, ... }: {
  imports = with nixosModules; [
    profiles.zfs
    profiles.graphical
    hardware.amdgpu.support-old
  ];

  fileSystems = {
    "/" = {
      device = "rpool/nixos";
      fsType = "zfs";
    };
    "/home" = {
      device = "rpool/nixos/home";
      fsType = "zfs";
    };
    "/boot" = {
      label = "boot";
      fsType = "vfat";
    };
  };

  # boot.zfs.arcSize = 2;

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  boot.zfs.enableUnstable = true;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  boot.loader.systemd-boot.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
} 
