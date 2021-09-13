{ nixosModules, ... }:

{
  imports = with nixosModules; [
    profiles.zfs
    profiles.graphical
    hardware.amdgpu.support-old
    hardware.fix-tearing
  ];

  services.xserver.dpi = 96;

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

  boot.zfs.arcSize = 2;

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  boot.loader.systemd-boot = {
    enable = true;
    # consoleMode = "max";
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
} 
