{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pijul
  ];
}
