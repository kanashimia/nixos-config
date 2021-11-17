{ nixosModules, pkgs, lib, config, ... }: {
  imports = with nixosModules; [
    apps.browsers.chromium
    apps.shells.zsh
    apps.terminals.st
    # apps.window-managers.xmonad
    profiles.activities.drawing
    profiles.activities.music
    profiles.basic
    profiles.pipewire
    profiles.users.kanashimia
    profiles.syncthing
    profiles.utils
    apps.window-managers.sway
    themes.colors
    themes.lightdm
  ];

  services.xserver.libinput = {
    enable = true;
    touchpad.disableWhileTyping = true;
  };

  # Enable SysRq key for unexpected situations.
  boot.kernel.sysctl."kernel.sysrq" = 1;

  # services.physlock.enable = true;

  # services.unclutter-xfixes.enable = true;
}

