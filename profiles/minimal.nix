{ lib, config, ... }:

{
  options.profiles.minimal = {
    enable = lib.mkEnableOption "minimal profile";
  };

  config = lib.mkIf config.profiles.minimal.enable {
    documentation = {
      enable = lib.mkDefault false;
      nixos.enable = false;
    };
    security.sudo.enable = false;
    #environment.noXlibs = true;
  };
}
