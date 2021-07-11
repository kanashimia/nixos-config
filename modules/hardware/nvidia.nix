{ lib, config, ... }:

let
cfg = config.hardware.nvidia;
in
{
  options.hardware.nvidia = {
    fixTearing = lib.mkEnableOption "nvidia mitigation for tearing in xorg";
  };

  config = {
    services.xserver.screenSection = lib.mkIf cfg.fixTearing ''
      Option "metamodes" "nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
    '';
  };
}
