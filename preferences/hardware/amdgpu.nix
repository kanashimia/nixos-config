{
  # Prefer amdgpu over radeon driver for SI/CIK cards.
  boot.kernelParams = [
    "radeon.si_support=0" "amdgpu.si_support=1" # GCN 1
    "radeon.cik_support=0" "amdgpu.cik_support=1" # GCN 2
  ];
}
