{ nixosModules, pkgs, ... }:

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

  environment.systemPackages = with pkgs; [ alsa-utils ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
}
