{
  # Use amdgpu driver for GCN 1 cards instead of radeon.
  boot.kernelParams = [
    "radeon.si_support=0"
    "amdgpu.si_support=1"
  ];

  # Fix xorg tearing meme once again.
  services.xserver.deviceSection = ''
    Option "TearFree" "true"
  '';
}

