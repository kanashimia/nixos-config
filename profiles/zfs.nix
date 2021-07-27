{ lib, config, ... }:

{
  options.profiles.zfs = {
    enable = lib.mkEnableOption "zfs profile";
  };

  config = lib.mkIf config.profiles.zfs.enable {
    networking.hostId = with builtins;
      substring 0 8 (hashString "md5" config.networking.hostName);

    boot.initrd.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;

    services.zfs.autoScrub.enable = true;
  };
}
