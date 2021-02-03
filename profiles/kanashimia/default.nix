{ conf-utils, pkgs, ... }:

{
  imports = [ ./xmonad ./vivaldi.nix ./rofi ];

  users.users.kanashimia = {
    uid = 1001;
    description = "Kanashimia";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "jackaudio"
    ];
  };
}
