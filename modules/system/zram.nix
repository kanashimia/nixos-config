{
  zramSwap.enable = true;

  # This is the size of a block device to be created, in a percentage of ram,
  # it doesnt reflect actual memory that is being used in any way.
  # Compression ratio expected to be at least 3x the size of a ram,
  # so having values above 100 is ok.
  zramSwap.memoryPercent = 200;

  # Swapping with zram is much much faster than paging so we prioritize it.
  boot.kernel.sysctl."vm.swappiness" = 190;
}
