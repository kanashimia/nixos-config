{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vivaldi
    steam
    libreoffice
  ];
}
