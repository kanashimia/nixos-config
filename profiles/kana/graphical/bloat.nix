{ pkgs, ... }:

let
vivaldi = pkgs.vivaldi.override {
  proprietaryCodecs = true;
  enableWidevine = true;
};
neofetch = pkgs.neofetch.overrideAttrs (old: {
  src = pkgs.fetchFromGitHub {
    owner = "dylanaraps";
    repo = "neofetch";
    rev = "6dd85d67fc0d4ede9248f2df31b2cd554cca6c2f";
    sha256 = "PZjFF/K7bvPIjGVoGqaoR8pWE6Di/qJVKFNcIz7G8xE=";
  };
});
in
{
  home.packages = with pkgs; [
    vivaldi
    #libreoffice-fresh
    qbittorrent
    jq
    neofetch
    zathura
    #gnome3.nautilus
  ];
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
  };
}
