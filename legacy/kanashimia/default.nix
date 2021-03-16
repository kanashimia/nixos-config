{ conf-utils, pkgs, ... }:

{
  imports = conf-utils.listFiles ./.;

  users.users.kanashimia = {
    uid = 1001;
    description = "Kanashimia";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "jackaudio"
      "realtime"
      "vboxusers"
      "docker"
    ];
  };
}
