{ pkgs, nixosModules, lib, ... }:

{
  imports = with nixosModules; [
    networking.networkd
    environment.xdg-user-dirs
    system.nix
    system.zram
    system.loader
    ssh-keys
    apps.shells.bash
    apps.shells.zsh
  ];

  # Documentation slows eval quite a lot.
  documentation.nixos.enable = false;

  # Some default programs that i always use.
  environment.variables.EDITOR = "kak";
  environment.defaultPackages = with pkgs; [
    gitMinimal kakoune rsync
  ];

  # Do not print sometimes helpful, but not always, info during boot,
  # so it is harder to debug system when something goes wrong.
  boot.kernelParams = [ "quiet" ];

  # Layout config.
  services.xserver = {
    xkbOptions = lib.concatStringsSep "," [
      "caps:swapescape"
      "compose:menu"
      "grp_led:num"
      "grp:rctrl_rshift_toggle"
    ];
    xkbVariant = "dvorak,ruu";
    layout = "us,ru";
  };

  # Use same layout for console.
  console.useXkbConfig = true;

  time.timeZone = "Europe/Kiev";
  i18n = {
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings.LC_TIME = "en_DK.UTF-8";
  };

  users.users.root.password = "root";
  users.mutableUsers = false;
}
