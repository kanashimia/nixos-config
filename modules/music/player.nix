{
  home-manager.users.kanashimia = { config, ... }: {
    programs.ncmpcpp.enable = true;
    services.mpd.enable = true;
    services.mpd.musicDirectory = "${config.home.homeDirectory}/Music";
  };
}
