{ lib, config, ... }:

{
  options.profiles.graphical.enable = lib.mkEnableOption "graphical profile";

  config = lib.mkIf config.profiles.graphical.enable {
    # Fix xorg tearing meme.
    hardware.amdgpu.fixTearing = true;
    hardware.nvidia.fixTearing = true;
    services.xserver.windowManager.xmonad.enable = true;

    users.users.kanashimia = {
      uid = 1000;
      description = "Kanashimia";
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      password = "kanashimia";
    };
  };
}
