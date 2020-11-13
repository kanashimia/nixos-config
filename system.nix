{ inputs, pkgs, nixpkgs, config, options, ... }:

{
  imports = [ ./overlays.nix ];

  nix.package = pkgs.nixFlakes;
  environment.systemPackages = with pkgs; [
    htop kakoune fd ripgrep git pciutils glxinfo unstable.manix tree dash linuxPackages.perf inxi xsel xclip xorg.xev xcalib
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

  security.polkit.enable = true;

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    displayManager.autoLogin = {
      enable = false;
      user = "kana";
    };
    desktopManager.session = [
      { name = "home-manager";
        start = ''
          ${pkgs.runtimeShell} $HOME/.hm-xsession
          waitPID=$!
        '';
      }
    ];
    # windowManager.xmonad = {
    #   enable = true;
    #   enableContribAndExtras = true;
    #   config = ./dotfiles/xmonad.hs;
    # };
 
    exportConfiguration = true;
    autoRepeatInterval = 30;
    autoRepeatDelay = 300;
  };


  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Logarithmic brightness control.
  hardware.brillo.enable = true;

  # Touchpad configuration.
  # Need MatchIsTouchpad "on" there,
  # otherwise it would change mouse settings too.
  services.xserver.libinput = {
    enable = true;
    naturalScrolling = true;
    accelSpeed = "-0.1";
    additionalOptions = ''MatchIsTouchpad "on"'';
  };
  
  # Ah, why isn't there one for mouse too?
  services.xserver.config = ''
    Section "InputClass"
      Identifier     "My mouse"
      Driver         "libinput"
      MatchIsPointer "on"
      Option "AccelSpeed" "-0.5"
      Option "AccelProfile" "flat"
    EndSection
  '';

  i18n.defaultLocale = "en_IE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    earlySetup = true;
    useXkbConfig = true;
  };

  services.xserver.layout = "us, ru";
  services.xserver.xkbOptions = "caps:swapescape, grp:rctrl_rshift_toggle, terminate:ctrl_alt_bksp";
  services.xserver.dpi = 96;

  services.xserver.displayManager.lightdm.greeters = {
    gtk = {
      enable = true;
      cursorTheme = {
        package = pkgs.breeze-qt5;
        name = "breeze_cursors";
        size = 16;
      };
    };
  };

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
