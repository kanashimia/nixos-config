{ lib, config, ... }:

{
  options.profiles.graphical.enable = lib.mkEnableOption "graphical profile";

  config = lib.mkIf config.profiles.graphical.enable {
    # Fix xorg tearing meme.
    hardware.amdgpu.fixTearing = true;
    hardware.nvidia.fixTearing = true;
  };
}
