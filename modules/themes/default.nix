{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.themes;
  defaultColors = {
    foreground = "#d5d5e1";
    background = "#202331";

    # black = "#4e5471";
    # red = "#f07178";
    # green = "#c3e88d";
    # yellow = "#ffc47c";
    # blue = "#82aaff";
    # purple = "#c792ea";
    # cyan = "#89ddff";
    # white = "#d5d5e1";
    # 
    # blackBr = "#676e95";
    # redBr = "#f07178";
    # greenBr = "#c3e88d";
    # yellowBr = "#ffc47c";
    # blueBr = "#82aaff";
    # purpleBr = "#c792ea";
    # cyanBr = "#89ddff";
    # whiteBr = "#d5d5e1";
    
    color0 = "#4e5471";
    color1 = "#f07178";
    color2 = "#c3e88d";
    color3 = "#ffc47c";
    color4 = "#82aaff";
    color5 = "#c792ea";
    color6 = "#89ddff";
    color7 = "#d5d5e1";
    color8 = "#676e95";
    color9 = "#f07178";
    color10 = "#c3e88d";
    color11 = "#ffc47c";
    color12 = "#82aaff";
    color13 = "#c792ea";
    color14 = "#89ddff";
    color15 = "#d5d5e1";
  };
  
  mkColorOption = name: {
    inherit name;
    value = mkOption {
      type = types.strMatching "#[a-fA-F0-9]{6}";
      description = "The ${name} color.";
    };
  };

  xresources = pkgs.writeText "xresources-colors"
    (concatStringsSep "\n"
      (mapAttrsToList (n: v: "*.${n}: ${v}") cfg.colors));
in {
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
