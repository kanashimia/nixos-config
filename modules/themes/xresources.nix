{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.themes;

  enabled = cfg.xresources.enable && cfg.enable;

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
  
  xresources = pkgs.writeText "xresources-colors"
    (concatStrings
      (mapAttrsToList
        (n: v: "*.${n}: ${v}\n")
        (toXresourcesColors cfg.colors)));
in
{
  options.themes = {
    xresources.enable = mkEnableOption "xresources themes";
  };

  config = mkIf enabled {
    services.xserver.displayManager.sessionCommands = ''
      ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xresources}
    '';
  };
}
