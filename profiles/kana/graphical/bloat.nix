{ pkgs, ... }:

let
vivaldi = pkgs.vivaldi.override {
  proprietaryCodecs = true;
  enableWidevine = true;
};
steam = pkgs.steam.override {
  extraPkgs = pkgs: with pkgs; [
    noto-fonts noto-fonts-cjk
  ];
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
    steam
    libreoffice-fresh
    qbittorrent
    jq
    krita
    neofetch
  ];
}
