{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rofi
  ];
}
