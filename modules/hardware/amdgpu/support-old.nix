{ config, lib, ... }:

let
  drivers = config.services.xserver.videoDrivers;
in {
  boot.kernelParams = lib.mkIf (lib.elem "amdgpu" drivers) [
    "radeon.si_support=0"  "amdgpu.si_support=1"  # GCN 1
    "radeon.cik_support=0" "amdgpu.cik_support=1" # GCN 2
  ];
}
