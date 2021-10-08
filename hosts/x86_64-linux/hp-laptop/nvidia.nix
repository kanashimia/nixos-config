{ lib, ... }:

{
  # Oh no.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Proprietary garbage.
  nixpkgs.config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) [
    "nvidia-x11" "nvidia-settings"
  ];

  # For an "amazing" intel + nvidia combo.
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    powerManagement = {
      enable = true;
      finegrained = true;
    };
  };

  services.xserver.dpi = 102;
}
