{
  zramSwap.enable = true;

  # This is the size of a block device to be created, in a percentage of ram,
  # it doesnt reflect actual memory that is being used in any way.
  # Compression ratio expected to be at least 3x the size of a ram,
  # so having values above 100 is ok.
  zramSwap.memoryPercent = 100;

  zramSwap.algorithm = "lz4";

  boot.kernel.sysctl = {
    # Swapping with zram is much much faster than paging so we prioritize it.
    "vm.swappiness" = 180;
    # "vm.swappiness" = 100;

    # With zstd, the decompression is so slow
    # that that there's essentially zero throughput gain from readahead.
    # Prevents uncompressing any more than you absolutely have to,
    # with a minimal reduction to sequential throughput.
    # The system reads only one page at a time from swap,
    # potentially reducing initial latency when accessing swapped-out pages.
    # This is advantageous when using ZRAM, as ZRAM provides fast access to swap space.
    # Reading only the required pages can improve performance without the overhead
    # of prefetching additional pages.
    # "vm.page-cluster" = 0;
    "vm.page-cluster" = 1;

    # This reduces reclaim activity during memory fragmentation
    # when high-order memory allocations are less critical.
    # This can optimize memory management for systems using ZRAM.
    # Since ZRAM reduces the need for high-order memory allocations,
    # the extra memory reclaim becomes unnecessary, improving overall performance.
    "vm.watermark_boost_factor" = 0;

    # Make the Kernel Swap Thread more aggressive in maintaining free memory.
    # This helps prevent applications from entering direct memory reclaim,
    # enhancing system responsiveness under memory pressure.
    # This is particularly beneficial for systems with ZRAM,
    # because it allows the system to better utilize ZRAM’s fast swap capabilities
    # by maintaining more free memory and reducing allocation stalls.
    "vm.watermark_scale_factor" = 125;

    "vm.dirty_bytes" = 268435456;
    "vm.dirty_background_bytes" = 134217728;
    "vm.max_map_count" = 2147483642;
    "fs.inotify.max_user_instances" = 1024;
  };
}
