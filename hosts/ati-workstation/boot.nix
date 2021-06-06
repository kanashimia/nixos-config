{
  #boot.initrd.availableKernelModules = [
  #  "ahci" "ohci_pci" "ehci_pci" "xhci_pci"
  #  "usb_storage" "usbhid" "sd_mod" "sr_mod"
  #];
  #boot.kernelModules = [ "kvm-amd" ];

  fileSystems = {
    "/".label = "nixos";
    "/boot".label = "boot";
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
  };
} 
