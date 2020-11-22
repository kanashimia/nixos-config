{ pkgs, ...}:

{
  xsession.profileExtra = ''
    ${pkgs.feh}/bin/feh --bg-fill ${./wallpaper.png}
  '';
}
