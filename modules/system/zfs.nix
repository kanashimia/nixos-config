{ lib, config, ... }: let
  cfg = config.boot.zfs;
in {
  options.boot.zfs.arcSize = lib.mkOption {
    default = null;
    type = with lib.types; nullOr int;
    example = "4G";
    description = "TODO";
  };

  config = lib.mkIf (cfg.enabled && cfg.arcSize != null) {
    boot.kernelParams = [ "zfs.zfs_arc_max=${toString (1073741824 * cfg.arcSize)}" ];
  };
}
