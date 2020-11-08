{ inputs, pkgs, nixpkgs, config, options, ... }:

{
  imports = [ ./overlays.nix ];

  nix.package = pkgs.nixFlakes;
  environment.systemPackages = with pkgs; [
    htop kakoune fd ripgrep git pciutils glxinfo unstable.manix tree dash linuxPackages.perf inxi xsel
  ];

  nix.extraOptions = "experimental-features = nix-command flakes";

  nixpkgs.config = {
    allowUnfree = true;
    vivaldi = {
      proprietaryCodecs = true;
      enableWideVine = true;
    };
    st.conf = builtins.readFile ./dotfiles/st.h;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    displayManager.autoLogin = {
      enable = false;
      user = "kana";
    };
    desktopManager.session = [{
      name = "home-manager";
      start = ''
        ${pkgs.runtimeShell} $HOME/.hm-xsession
        waitPID=$!
      '';
    }];
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ./dotfiles/xmonad.hs;
    };
 
    exportConfiguration = true;
    autoRepeatInterval = 30;
    autoRepeatDelay = 300;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  hardware.brillo.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    naturalScrolling = true;
    accelSpeed = "-0.1";
  };

  i18n.defaultLocale = "en_IE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    earlySetup = true;
    useXkbConfig = true;
  };

  services.xserver.layout = "us";
  services.xserver.xkbOptions = "caps:swapescape, terminate:ctrl_alt_bksp";
  services.xserver.dpi = 96;
  
  fonts.fontconfig.dpi = 96;
  fonts.fonts = with pkgs; [
    fira-code
  ];
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
