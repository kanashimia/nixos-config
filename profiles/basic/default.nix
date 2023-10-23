{ pkgs, lib, ... }: {
  imports = [
    ./networkd.nix
    ./xdg-user-dirs.nix
    ./nix.nix
    ./zram.nix
    ./loader.nix
    ./ssh-keys.nix
    ./bash.nix
    ./zsh
    ./aliases.nix
  ];

  # Documentation slows eval quite a lot.
  documentation.nixos.enable = false;

  # Some default programs that i always use.
  environment.variables.EDITOR = "kak";
  environment.defaultPackages = with pkgs; [
    git kakoune rsync helix
  ];

  # Don't create ~/.lesshst
  environment.variables.LESSHISTFILE = "-";

  # Do not print sometimes helpful, but not always, info during boot,
  # so it is harder to debug system when something goes wrong.
  # boot.kernelParams = [ "quiet" "vt.global_cursor_default=0" "fbcon=nodefer" ];
  boot.kernelParams = [ "quiet" ];

  boot.initrd.systemd.enable = true;

  systemd.coredump.extraConfig = ''
    Storage=none
    ProcessSizeMax=0
  '';

  networking.firewall.enable = true;

  console.keyMap = "dvorak";
  # console.earlySetup = true;

  # Use same layout for console.
  # console.useXkbConfig = true;

  services.dbus.implementation = "broker";

  time.timeZone = "Europe/Kyiv";
  i18n = {
    supportedLocales = [ 
      # "en_US.UTF-8"
      # "en_IE.UTF-8"
      # "en_DK.UTF-8"
      # "uk_UA.UTF-8"
      # "ja_JP.UTF-8"
      "all" 
    ];
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings.LC_TIME = "en_DK.UTF-8";
  };

  users.users.root.password = null;
  users.mutableUsers = false;

  security.sudo.enable = false;
}
