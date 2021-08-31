{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    syntaxHighlighting.enable = true;
    interactiveShellInit = builtins.readFile ./zshrc;
    shellInit = "zsh-newuser-install () {}";
    # promptInit = "
    #   PS1='\n %~ ›'
    # ";
  };

  users.defaultUserShell = pkgs.zsh;
}
