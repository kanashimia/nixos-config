{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bitwarden
  ];
}
