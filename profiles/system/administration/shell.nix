{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
  users.defaultUserShell = pkgs.zsh;
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch -L";
    nrb = "sudo nixos-rebuild boot -L";
    nrr = "sudo nixos-rebuild rollback -L";
  };
}
