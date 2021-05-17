{ pkgs, ... }:

let
xcursor = pkgs.stdenv.mkDerivation {
  name = "global-cursor-theme";
  unpackPhase = "true";
  outputs = [ "out" ];
  installPhase = ''
    mkdir -p $out/share/icons/default
    cat << EOF > $out/share/icons/default/index.theme
    [Icon Theme]
    Inherits=breeze_cursors
    EOF
  '';
};
in
{
  #environment.variables.XCURSOR_THEME = "breeze_cursors";
  #environment.systemPackages = with pkgs; [
  #  xcursor breeze-qt5 gnome3.adwaita-icon-theme
  #];
  #services.xserver.displayManager.sessionCommands = ''
  #  ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
  #'';
  #environment.etc."xdg/gtk-3.0/settings.ini".text = ''
  #  [Settings]
  #  gtk-cursor-theme-name=breeze_cursors
  #'';
}
