{ pkgs, nixosModules, ... }: {
  imports = with nixosModules; [ environment.aliases ];

  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    syntaxHighlighting.enable = true;
    interactiveShellInit = builtins.readFile ./zshrc.sh;
    promptInit = builtins.readFile ./prompt.sh;
    shellInit = "zsh-newuser-install () {}";
  };

  users.defaultUserShell = pkgs.zsh;
}
