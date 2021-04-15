{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.themes;
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

  toXresourcesColors = c: {
    inherit (c) background foreground;

    color0 = c.black;
    color1 = c.red;
    color2 = c.green;
    color3 = c.yellow;
    color4 = c.blue;
    color5 = c.purple;
    color6 = c.cyan;
    color7 = c.white;

    color8 = c.blackBr;
    color9 = c.redBr;
    color10 = c.greenBr;
    color11 = c.yellowBr;
    color12 = c.blueBr;
    color13 = c.purpleBr;
    color14 = c.cyanBr;
    color15 = c.whiteBr;
  };
  
  mkColorOption = name: {
    inherit name;
    value = mkOption {
      type = types.strMatching "#[a-fA-F0-9]{6}";
      description = "The ${name} color.";
    };
  };

  xresources = pkgs.writeText "xresources-colors"
    (concatStrings
      (mapAttrsToList
        (n: v: "*.${n}: ${v}\n")
        (toXresourcesColors cfg.colors)));
in {
  imports = [ ./gtk.nix ];
  
  options.themes = {
    enable = mkEnableOption "custom themes";

    colors = mkOption {
      type = types.attrsOf types.str;
      default = defaultColors;
    };

    xresources.enable = mkEnableOption "xresources themes";
  };

  config = mkIf true {
    services.xserver.displayManager.sessionCommands =
      mkIf true ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xresources}
      '';
  };
}
