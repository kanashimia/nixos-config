{ pkgs, lib, ... }: {
  imports = [
    ./networking.nix
    ./xdg-user-dirs.nix
    ./nix.nix
    ./zram.nix
    ./system.nix
    ./ssh-keys.nix
    ./bash.nix
    ./zsh
    ./aliases.nix
  ];

  # Documentation slows eval quite a lot.
  documentation.nixos.enable = false;

  # Useless stuff.
  programs.less.lessopen = null;
  documentation.info.enable = false;

  # Some default programs that i always use.
  environment.variables.EDITOR = "hx";
  environment.variables.LESS = "-RiF --mouse --wheel-lines=3";
  environment.defaultPackages = with pkgs; [
    git kakoune rsync helix
  ];

  # Locale and keymaps
  console.keyMap = "dvorak";
  time.timeZone = "Europe/Kyiv";
  i18n = {
    supportedLocales = [ "all" ];
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings = {
      LC_COLLATE = "C.UTF-8";
    };
  };
}
