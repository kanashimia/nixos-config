{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    theme = ./theme.rasi;
    font = "Fira Code 12";
    extraConfig = ''
      rofi.modi: drun,run,window
      rofi.sort: true
    '';
  };
}
