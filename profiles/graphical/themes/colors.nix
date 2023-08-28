{ lib, ... }: let
  defaultColors = rec {
    foreground = "#d5d5e1";
    foregroundBr = "#acaccd";

    background = "#15171f";
    backgroundBr = "#1f222e";
    backgroundDim = "#0b0c10";

    middleground = "#292d3d";

    accent = blue;

    black = "#393e53";
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
  
  adwaitaColors = rec {
    foreground = "#dfdfdf";
    foregroundBr = "#ffffff";

    background = "#2c2c2c";
    backgroundBr = "#535353";
    backgroundDim = "#282828";

    middleground = "#474747";

    accent = blue;

    black = "#393e53";
    red = "#f07178";
    green = "#c3e88d";
    yellow = "#ffc47c";
    blue = "#82aaff";
    purple = "#c792ea";
    cyan = "#89ddff";
    white = foreground;

    blackBr = "#676e95";
    redBr = "#f07178";
    greenBr = "#c3e88d";
    yellowBr = "#ffc47c";
    blueBr = "#82aaff";
    purpleBr = "#c792ea";
    cyanBr = "#89ddff";
    whiteBr = foregroundBr;
  };

  adwaitaColorsLight = rec {
    foreground = "#000000";
    foregroundBr = "#333333";

    background = "#ffffff";
    backgroundBr = "#f8f8f8";
    backgroundDim = "#c8c8c8";

    middleground = "#e1e1e1";

    accent = blue;

    black = "#393e53";
    red = "#f07178";
    green = "#c3e88d";
    yellow = "#ffc47c";
    blue = "#82aaff";
    purple = "#c792ea";
    cyan = "#89ddff";
    white = foreground;

    blackBr = "#676e95";
    redBr = "#f07178";
    greenBr = "#c3e88d";
    yellowBr = "#ffc47c";
    blueBr = "#82aaff";
    purpleBr = "#c792ea";
    cyanBr = "#89ddff";
    whiteBr = foregroundBr;
  };

  newColors = rec {
    foreground = "#ACAFB9";
    foregroundBr = "#acaccd";

    background = "#222428";
    backgroundBr = "#1f222e";
    backgroundDim = "#0b0c10";

    middleground = "#292d3d";

    accent = blue;

    black = "#393e53";
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

  tokyoNightColors = rec {
    foreground = "#c0caf5";
    foregroundBr = foreground;

    background = "#1a1b26";
    backgroundBr = background;
    backgroundDim = background;

    middleground = "#ff0000";

    accent = blue;

    black = "#414868";
    red = "#f7768e";
    green = "#9ece6a";
    yellow = "#e0af68";
    blue = "#7aa2f7";
    purple = "#bb9af7";
    cyan = "#7dcfff";
    white = "#a9b1d6";

    blackBr = "#414868";
    redBr = "#f7768e";
    greenBr = "#9ece6a";
    yellowBr = "#e0af68";
    blueBr = "#7aa2f7";
    purpleBr = "#bb9af7";
    cyanBr = "#7dcfff";
    whiteBr = "#c0caf5";
  };
  
  mkColorOption = name: default: lib.mkOption {
    inherit default;
    type = lib.types.strMatching "#[a-fA-F0-9]{6}";
    description = "Value of the ${name} color";
  };
in {
  options.themes.colors = lib.mapAttrs mkColorOption defaultColors;
}
