{ config, lib, ... }:

with lib;

let
  defaultColors = rec {
    foreground = "#d5d5e1";
    foregroundBr = "#acaccd";

    background = "#15171f";
    backgroundBr = "#1f222e";
    backgroundDim = "#0b0c10";

    middleground = "#292d3d";

    accent = blue;

    black = "#4e5471";
    red = "#f07178";
    green = "#c3e88d";
    yellow = "#ffc47c";
    blue = "#82aaff";
    purple = "#c792ea";
    cyan = "#89ddff";
    white = "#d5d5e1";

    blackBr = "#676e95";
    redBr = "#f07178";
    greenBr = "#c3e88d";
    yellowBr = "#ffc47c";
    blueBr = "#82aaff";
    purpleBr = "#c792ea";
    cyanBr = "#89ddff";
    whiteBr = "#d5d5e1";
  };
  
  mkColorOption = name: value: mkOption {
    default = value;
    type = types.strMatching "#[a-fA-F0-9]{6}";
    description = "Value of the ${name} color";
  };
in
{
  options.kanashimia.themes = {
    colors = mapAttrs mkColorOption defaultColors;
  };
}
