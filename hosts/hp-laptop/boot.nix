{ nixosModules, ... }:

{
  imports = with nixosModules.profiles; [
    zfs
    graphical
  ];

  # Support booting from NVMe SSD.
  boot.initrd.availableKernelModules = [ "nvme" ];

  # Enable systemd boot, because it is superior.
  boot.loader.systemd-boot.enable = true;

  fileSystems = {
    "/" = {
      device = "rpool/nixos";
      fsType = "zfs";
    };
    "/var" = {
      device = "rpool/nixos/var";
      fsType = "zfs";
    };
    "/home" = {
      device = "rpool/nixos/home";
      fsType = "zfs";
    };
    "/nix" = {
      device = "rpool/nixos/nix";
      fsType = "zfs";
    };
    "/boot" = {
      label = "boot";
      fsType = "vfat";
    };
  };

  # Enable proprietary non-free garbage.
  hardware.enableRedistributableFirmware = true;

  # Use updated microcode because hardware bugs are fun.
  hardware.cpu.intel.updateMicrocode = true;

  # Laptop powersaving, or something.
  services.tlp.enable = true;
}
