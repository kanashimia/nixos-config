{ pkgs, ... }:

{
  home-manager.users.kanashimia = { config, ... }: {
    programs.ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp.override { visualizerSupport = true; };
      settings = {
        visualizer_color = "blue";
      };
    };
    services.mpd = {
      network.startWhenNeeded = true;
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/Music";
      extraConfig = ''
        audio_output {
          type "pulse"
          name "pulse audio"
        }
        audio_output {
          type   "fifo"
          name   "visualizer_fifo"
          path   "/tmp/mpd.fifo"
          format "44100:16:2"
        }
      '';
    };
  };
}
