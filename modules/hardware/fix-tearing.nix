{ config, lib, ... }:

let
  drivers = config.services.xserver.videoDrivers;
in {
  services.xserver.deviceSection = lib.mkIf (lib.elem "amdgpu" drivers) ''
    Option "TearFree" "true"
  '';

  services.xserver.screenSection = lib.mkIf (lib.elem "nvidia" drivers) ''
    Option "metamodes" "nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
  '';
}
