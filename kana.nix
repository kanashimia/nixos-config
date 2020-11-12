{ pkgs, ... }:

let
profile = {
  home.packages = with pkgs; [
    fortune neofetch gparted st rofi vivaldi discord steam flameshot libreoffice
  ];

  programs = {
    htop.enable = true;
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
      ${pkgs.feh}/bin/feh --bg-fill ${./dotfiles/wallpaper.png}
    '';
  };

  #services.picom = {
  #  enable = true;
  #  vSync = true;
  #};
  # home.sessionVariables = {
  #   KAKOUNE_POSIX_SHELL = "${pkgs.dash}/bin/dash";
  #   EDITOR = "${pkgs.kakoune}";
  # };
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
