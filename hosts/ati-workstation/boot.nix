{
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
    amdgpu.supportOldCards = true;
  };

  boot.loader.systemd-boot = {
    enable = true;
    # consoleMode = "max";
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  profiles = {
    graphical.enable = true;
    zfs.enable = true;
  };
} 
