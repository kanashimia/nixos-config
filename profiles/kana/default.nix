{ conf-utils, pkgs, ... }:

{
  home-manager.users.kana.imports =
    conf-utils.listFilesInFolders ./.;

  programs.fish.enable = true;

  users.users.kana = {
    uid = 1001;
    description = "Kanashimia";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    shell = pkgs.fish;
  };
}
