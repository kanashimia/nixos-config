{ conf-utils, pkgs, ... }:

{
  home-manager.users.kana = {
    imports = conf-utils.listFilesInFolders ./.;
    _module.args = {
      inherit conf-utils;
    };
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.enableBashCompletion = true;

  users.users.kana = {
    uid = 1001;
    description = "Kanashimia";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "jackaudio"
    ];
    shell = pkgs.fish;
  };
}
