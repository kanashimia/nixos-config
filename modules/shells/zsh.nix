{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    syntaxHighlighting.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
}
