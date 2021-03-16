{ pkgs, ... }:

{
  users.mutableUsers = false;

  users.users.root.hashedPassword = pkgs.lib.fileContents ./password;

  users.users.kanashimia = {
    uid = 1001;
    description = "Kanashimia";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "jackaudio"
      # "realtime"
      "docker"
    ];
    hashedPassword = pkgs.lib.fileContents ./password;
  };

  users.motd = ''
    Kali linux is the best linux distribution for beginners.
  '';
}
