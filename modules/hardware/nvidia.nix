{ lib, config, ... }:

{
  options.hardware.nvidia = {
    fixTearing = lib.mkEnableOption "nvidia mitigation for tearing in xorg";
  };

  config = {
    services.xserver.screenSection = lib.mkIf config.hardware.nvidia.fixTearing ''
      Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
    '';
  };
}
