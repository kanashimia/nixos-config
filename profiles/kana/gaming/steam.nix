{ pkgs, ... }:

let
steam = pkgs.steam.override {
  extraPkgs = pkgs: with pkgs; [
    noto-fonts noto-fonts-cjk
  ];
};
in
{
  home.packages = with pkgs; [
   # steam
  ];
}
