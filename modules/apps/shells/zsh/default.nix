{ pkgs, nixosModules, ... }:

{
  imports = with nixosModules; [ environment.aliases ];

  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    syntaxHighlighting.enable = true;
    interactiveShellInit = builtins.readFile ./zshrc;
    shellInit = "zsh-newuser-install () {}";
    promptInit = ''
      PS1=
      PS1+=$'\n'
      PS1+='%F{cyan}%~%f'
      PS1+='%(2L. %F{red}nested%f.)'
      PS1+=$'\n'
      PS1+='%F{%(?.green.red)}%(!.!.›)%f'
    '';
  };

  users.defaultUserShell = pkgs.zsh;
}
