{
  # Use in-memory compression-based swap.
  zramSwap.enable = true;
  zramSwap.memoryPercent = 200;

  boot.kernel.sysctl."vm.swappiness" = 190;
}
