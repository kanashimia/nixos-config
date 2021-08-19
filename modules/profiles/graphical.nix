{ nixosModules, ... }:

{
  imports = with nixosModules; [
    profiles.basic
    window-managers.xmonad
    profiles.users.kanashimia
    shells.zsh
  ];

  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.disableWhileTyping = true;

  # Enable SysRq key for unexpected situations.
  boot.kernel.sysctl."kernel.sysrq" = 1;
}
