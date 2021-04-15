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

  # Fix xorg tearing meme.
  services.xserver.screenSection = ''
    Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
  '';
}
