{ pkgs, ... }:

let
profile = {
  home.packages = with pkgs; [
    fortune neofetch gparted st rofi vivaldi
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
    };
    git = {
      enable = true;
      userEmail = "nikita20001116@gmail.com";
      userName = "Nikita Ursol";
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
    initExtra = "${pkgs.feh}/bin/feh --bg-fill ${./dotfiles/wallpaper.png}";
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
