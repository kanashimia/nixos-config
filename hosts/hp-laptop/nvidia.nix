{
  # Oh no.
  services.xserver.videoDrivers = [ "nvidia" ];

  # For "amazing" intel + nvidia combo.
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime = {
    sync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Proprietary garbage.
  nixpkgs.config.allowUnfree = true;
}
