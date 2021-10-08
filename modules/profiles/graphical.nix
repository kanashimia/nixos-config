{ nixosModules, ... }:

{
  imports = with nixosModules; [
    apps.browsers.chromium
    apps.shells.zsh
    apps.terminals.st
    apps.window-managers.xmonad
    profiles.activities.drawing
    profiles.activities.music
    profiles.basic
    profiles.pipewire
    profiles.users.kanashimia
    profiles.syncthing
    profiles.utils
    themes.colors
    themes.lightdm
  ];

  services.xserver.libinput = {
    enable = true;
    touchpad.disableWhileTyping = true;
  };

  # Enable SysRq key for unexpected situations.
  boot.kernel.sysctl."kernel.sysrq" = 1;
}

