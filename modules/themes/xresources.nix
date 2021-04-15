{ pkgs, colors, ... }:

let
config = pkgs.writeText "config" ''
  *.foreground: #${colors.foreground}
  *.background: #${colors.background}
  *.color0: #${colors.black}
  *.color1: #${colors.red}
  *.color2: #${colors.green}
  *.color3: #${colors.yellow}
  *.color4: #${colors.blue}
  *.color5: #${colors.purple}
  *.color6: #${colors.cyan}
  *.color7: #${colors.white}
  *.color8: #${colors.blackBr}
  *.color9: #${colors.redBr}
  *.color10: #${colors.greenBr}
  *.color11: #${colors.yellowBr}
  *.color12: #${colors.blueBr}
  *.color13: #${colors.purpleBr}
  *.color14: #${colors.cyanBr}
  *.color15: #${colors.whiteBr}
  Xcursor.theme: breeze_cursors
'';
in
{
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge ${config}
  '';
}
