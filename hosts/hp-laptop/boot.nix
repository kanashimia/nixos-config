{ pkgs, ... }:

{
  # Enable something, was generated automatically.
  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "kvm_intel"
  ];

  # Enable systemd boot, because it is superior.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.editor = false;
    timeout = 0;
  };

  # Drives.
  fileSystems."/".label = "nixos";
  fileSystems."/boot".label = "boot";

  # Enable proprietary non-free garbage.
  hardware.enableRedistributableFirmware = true;

  # Use updated microcode because hardware bugs are fun.
  hardware.cpu.intel.updateMicrocode = true;
}
