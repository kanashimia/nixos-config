{ pkgs, conf-utils,... }:

{
  # Import users and config files.
  imports = conf-utils.listFiles ../users ++ [
    ./pkgs.nix
    ./xorg.nix
  ];

  # Enable flake support.
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # Automatically optimize /nix/store
  nix.autoOptimiseStore = true;

  # Automatically delete old generations.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Home manager config.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Default locale.
  i18n.defaultLocale = "en_IE.UTF-8";

  # Font Config.
  fonts.fontconfig.dpi = 96;
  fonts.fonts = with pkgs; [
    fira-code
  ];

  # Console config.
  console = {
    font = "Lat2-Terminus16";
    earlySetup = true;
  };
  console.colors = [
    "000000"
    "f07178"
    "c3e88d"
    "ffc47c"
    "82aaff"
    "c792ea"
    "89ddff"
    "d5d5e1"

    "4e5471"
    "f07178"
    "c3e88d"
    "ffc47c"
    "82aaff"
    "c792ea"
    "89ddff"
    "d5d5e1"
  ];
}
