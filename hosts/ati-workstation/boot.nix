{
  fileSystems = {
    "/".label = "nixos";
    "/boot".label = "boot";
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    amdgpu.supportOldCards = true;
  };

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
  };

  profiles.graphical.enable = true;
} 
