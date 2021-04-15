{ pkgs, ... }:

{
  # Use in-memory compression-based swap.
  zramSwap.enable = true;
  zramSwap.memoryPercent = 200;

  # Using vm.swappiness 100+ requires linux 5.8 and later.
  boot.kernel.sysctl."vm.swappiness" = 190;
}
