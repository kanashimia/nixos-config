{
  # Enable something, was generated automatically.
  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "alcor" "sd_mod" "kvm_intel"
  ];

  # Enable systemd boot, because it is superior.
  boot.loader.systemd-boot.enable = true;

  fileSystems = {
    "/".label = "nixos";
    "/boot".label = "boot";
  };

  # Enable proprietary non-free garbage.
  hardware.enableRedistributableFirmware = true;

  # Use updated microcode because hardware bugs are fun.
  hardware.cpu.intel.updateMicrocode = true;

  profiles.graphical.enable = true;

  # Laptop powersaving, or something.
  services.tlp.enable = true;
}
