{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ncmpcpp
  ];
  
  services.mpd.enable = true;
  services.mpd.startWhenNeeded = true;
}
