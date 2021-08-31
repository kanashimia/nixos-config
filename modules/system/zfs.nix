{ lib, config, ... }:

with lib;

let
  cfg = config.boot.zfs;
in
{
  options.boot.zfs.arcSize = mkOption {
    default = null;
    type = types.nullOr types.int;
    example = "4G";
    description = "TODO";
  };

  config = mkIf (cfg.enabled && cfg.arcSize != null) {
    boot.kernelParams = [ "zfs.zfs_arc_max=${toString (1073741824 * cfg.arcSize)}" ];
  };
}
