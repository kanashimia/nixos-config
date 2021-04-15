{ pkgs, ... }:

{
  #boot.initrd.availableKernelModules = [
  #  "ahci" "ohci_pci" "ehci_pci" "xhci_pci"
  #  "usb_storage" "usbhid" "sd_mod" "sr_mod"
  #];
  #boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/".label = "nixos";
  fileSystems."/boot".label = "boot";

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  boot.loader = {
    systemd-boot.enable = true;
    timeout = 0;
    efi.canTouchEfiVariables = true;
  };

  boot.kernelParams = [ "quiet" ];
} 
