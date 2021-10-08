{ config, lib, ... }:

let
  drivers = config.services.xserver.videoDrivers;
in {
  # For SI/CIK cards radeon driver is used by default, 
  # this makes them to use amdgpu instead.
  boot.kernelParams = lib.mkIf (lib.elem "amdgpu" drivers) [
    "radeon.si_support=0"  "amdgpu.si_support=1"  # GCN 1
    "radeon.cik_support=0" "amdgpu.cik_support=1" # GCN 2
  ];
}
