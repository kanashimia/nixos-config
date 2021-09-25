{ config, nixosModules, ... }:

{
  imports = with nixosModules; [
    system.zfs
  ];

  networking.hostId = with builtins;
    substring 0 8 (hashString "md5" config.networking.hostName);

  boot.supportedFilesystems = [ "zfs" ];

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };
}
