{ config, lib, ... }:

{
  # This is the size of a block device to be created, in a percentage of ram,
  # it doesnt reflect actual memory that is being used in any way.
  # We expect at least 3x compression ratio, so having values above 100 is ok.
  zramSwap.memoryPercent = 200;

  # Prioritize swapping to paging
  boot.kernel.sysctl."vm.swappiness" = lib.mkIf config.zramSwap.enable 190;
}
