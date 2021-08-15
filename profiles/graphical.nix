{ lib, config, nixosModules, ... }:

{
  options.profiles.graphical.enable = lib.mkEnableOption "graphical profile";

  imports = with nixosModules; [
    window-managers.xmonad
    hardware.fix-tearing
  ];

  config = lib.mkIf config.profiles.graphical.enable {
    # Fix xorg tearing meme.
    services.xserver.libinput.enable = true;

    # Enable SysRq key for unexpected situations.
    boot.kernel.sysctl."kernel.sysrq" = 1;
  };
}
