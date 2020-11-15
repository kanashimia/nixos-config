{ pkgs, ... }:

let
profile = {
  home.packages = with pkgs; [
    fortune neofetch gparted st vivaldi discord steam flameshot libreoffice
  ];

  programs = {
    htop.enable = true;
    rofi = {
      enable = true;
      package = pkgs.unstable.rofi;
      theme = ./dotfiles/rofi.rasi;
      font = "Fira Code 12";
      extraConfig = "rofi.modi: drun,run,window";
    };
    tmux = {
      enable = true;
      extraConfig = builtins.readFile ./dotfiles/tmux.conf;
    };
    fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./dotfiles/fish.fish;
      shellAbbrs = {
        syu = "sudo nixos-rebuild switch";
        syr = "sudo nixos-rebuild switch --rollback";
      };
      plugins = [
        { name = "spacefish";
          src = pkgs.fetchFromGitHub {
            owner = "matchai";
            repo = "spacefish";
            rev = "adbb02a9866547f235380ea9db8c71424bd6e611";
            sha256 = "Asz+m17DsPRPAFLb9mU+L7rubwAxe4CvvSZpxCdTiMU=";
          };
        }
      ];
    };
    git = {
      enable = true;
      userEmail = "nikita20001116@gmail.com";
      userName = "Nikita Ursol";
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  xsession.pointerCursor = {
    package = pkgs.breeze-qt5;
    name = "breeze_cursors";
    size = 16;
  };

  services = {
    unclutter.enable = true;
  };
  
  xsession.windowManager = {
    xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ./dotfiles/xmonad.hs;
    };
  };

  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    initExtra = ''
      ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
      ${pkgs.feh}/bin/feh --bg-fill ${./dotfiles/wallpaper.png}
    '';
  };
};
in
{
  home-manager.users.kana = {
    imports = [ profile ];
  };

  environment.shells = [ pkgs.fish ];

  users.users.kana = {
    uid = 1001;
    description = "Kanashimia";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.fish;
  };
}
