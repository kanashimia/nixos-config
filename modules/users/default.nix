{ pkgs, ... }:

{
  users.users.root.initialHashedPassword = pkgs.lib.fileContents ./password;

  users.users.kanashimia = {
    uid = 1000;
    description = "Kanashimia";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "jackaudio"
      "docker"
      "adbusers"
    ];
    initialHashedPassword = pkgs.lib.fileContents ./password;
  };

  users.motd = ''
    Kali linux is the best linux distribution for beginners.
  '';
}
