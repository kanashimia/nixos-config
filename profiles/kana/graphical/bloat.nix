{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vivaldi
    steam
    libreoffice-fresh
    qbittorrent
    jq
    krita
  ];
}
