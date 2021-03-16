{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ mlterm ];
}
