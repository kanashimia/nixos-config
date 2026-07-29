{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    syntaxHighlighting.enable = false;
    interactiveShellInit = builtins.readFile ./zshrc.sh + ''
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
    '';
    # setOptions = [];
    # interactiveShellInit = builtins.readFile ./zshrc.sh + ''
    #   source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh
    # '';
    promptInit = builtins.readFile ./prompt.sh;
    shellInit = "zsh-newuser-install () {}";
  };

  users.defaultUserShell = pkgs.zsh;
}
