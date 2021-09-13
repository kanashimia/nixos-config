{ lib, config, pkgs, inputs, nixosModules, ... }:

{
  imports = with nixosModules; [
    networking.networkd
    environment.xdg-user-dirs
    system.nix
    system.zram
    system.loader
  ];

  # Some default programs that i always use.
  environment.systemPackages = with pkgs; [ gitMinimal kakoune ];

  # Do not print sometimes helpful, but not always, info during boot,
  # so it is harder to debug system when something goes wrong.
  # boot.kernelParams = [ "quiet" ];

  # Layout config.
  services.xserver = {
    xkbOptions = "caps:swapescape,grp:rctrl_rshift_toggle,compose:menu,grp_led:num";
    xkbVariant = "dvorak,,";
    layout = "us,ru,ua";
  };

  # Use same layout for console.
  console.useXkbConfig = true;

  i18n.defaultLocale = "en_IE.UTF-8";
  time.timeZone = "Europe/Kiev";

  users.users.root.password = "root";
  # users.mutableUsers = false;
}
