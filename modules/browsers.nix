{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox nyxt qutebrowser socat ungoogled-chromium
  ];
}
