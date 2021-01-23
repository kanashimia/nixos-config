{ pkgs, ... }:

{
  home.packages = with pkgs; [
    noto-fonts noto-fonts-cjk noto-fonts-extra
  ];
}
