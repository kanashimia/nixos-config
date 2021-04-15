{ pkgs, config, ... }:

{
  environment.etc."xdg/alacritty/alacritty.yml".source = pkgs.substituteAll ({
    src = ./alacritty.yml;
  } // config.themes.colors);
}
