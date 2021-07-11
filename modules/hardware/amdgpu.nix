{ lib, config, ... }:

let
cfg = config.hardware.amdgpu;
in
{
  options.hardware.amdgpu = {
    supportOldCards = lib.mkEnableOption ''
      Add support to amdgpu for SI/CIK (GCN 1/2) cards.
      This disables radeon driver support for such cards.
    '';
    fixTearing = lib.mkEnableOption "amdgpu mitigation for tearing in xorg";
  };

  config = {
    boot.kernelParams = lib.mkIf cfg.supportOldCards [
      "radeon.si_support=0"  "amdgpu.si_support=1"  # GCN 1
      "radeon.cik_support=0" "amdgpu.cik_support=1" # GCN 2
    ];

    services.xserver.deviceSection = lib.mkIf cfg.fixTearing ''
      Option "TearFree" "true"
    '';
  };
}
