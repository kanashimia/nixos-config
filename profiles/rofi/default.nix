{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.unstable.rofi;
    theme = ./theme.rasi;
    font = "Fira Code 12";
    extraConfig = "rofi.modi: drun,run,window";
  };
}
