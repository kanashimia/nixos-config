{ pkgs, ... }:

{
  services.xserver.displayManager.lightdm = {
    background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
    greeters.gtk.indicators = [ "~host" "~spacer" "~session" "~power" ];
  };
}
