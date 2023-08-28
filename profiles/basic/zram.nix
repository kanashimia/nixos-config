{
  zramSwap.enable = true;

  # This is the size of a block device to be created, in a percentage of ram,
  # it doesnt reflect actual memory that is being used in any way.
  # Compression ratio expected to be at least 3x the size of a ram,
  # so having values above 100 is ok.
  zramSwap.memoryPercent = 200;

  boot.kernel.sysctl = {
    # Swapping with zram is much much faster than paging so we prioritize it.
    "vm.swappiness" = 180;
    # With zstd, the decompression is so slow
    # that that there's essentially zero throughput gain from readahead.
    # Prevents uncompressing any more than you absolutely have to,
    # with a minimal reduction to sequential throughput
    "vm.page-cluster" = 0;
  };
}
