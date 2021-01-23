{ conf-utils, pkgs, ...}:

let
nkrita = pkgs.krita.overrideAttrs (old: {
  patchPhase = ''
    substituteInPlace ./plugins/impex/jpeg/krita_jpeg.desktop --replace ";jpeg/jfif" ""
  '';
});
in
{
  # Allow unfree pkgs.
  nixpkgs.config.allowUnfree = true;

  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  #services.gnome3.gnome-keyring.enable = true;

  # Key input diagnostic.
  environment.systemPackages = with pkgs; [
      xorg.xev
      gparted
      xterm
      xst
      # nkrita
  ];
}
