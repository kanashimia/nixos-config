{ lib, nixosModules, ... }:

{
  imports = with nixosModules; [
    profiles.basic
  ];

  documentation = {
    enable = lib.mkDefault false;
    nixos.enable = false;
  };
  security.sudo.enable = false;
  #environment.noXlibs = true;
}
