{ pkgs, ... }:

{
  services.xserver.displayManager.lightdm = {
    background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
    greeters.gtk = {
      indicators = [ "~spacer" "~session" "~language" "~power" ];
      #enable = true;
      #cursorTheme = {
      #  package = pkgs.breeze-qt5;
      #  name = "breeze_cursors";
      #  size = 16;
      #};
      #theme.package = pkgs.materia-theme;
      #theme.name = "Materia-dark";
      #iconTheme.package = pkgs.papirus-icon-theme;
      #iconTheme.name = "Papirus-Dark";
    };
  };
}
