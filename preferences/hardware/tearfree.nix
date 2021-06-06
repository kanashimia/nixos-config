{
  # Fix xorg tearing meme.
  services.xserver.deviceSection = ''
    Option "TearFree" "true"
  '';

  services.xserver.screenSection = ''
    Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
  '';
}
