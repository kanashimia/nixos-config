{ pkgs, ... }:

{
  # programs.zsh = {
  #   enable = true;
  #   enableCompletion = true;
  #   autosuggestions.enable = true;
  #   syntaxHighlighting.enable = true;
  # };
  # users.defaultUserShell = pkgs.zsh;
  programs.bash.promptInit = pkgs.lib.readFile (pkgs.substituteAll {
    src = ./prompt.sh;
    inherit (pkgs) gitstatus;
  });

  programs.bash.interactiveShellInit = ''
    source ${pkgs.fzf}/share/fzf/key-bindings.bash
    export HISTCONTROL=ignoreboth:erasedups
  '';
  environment.systemPackages = with pkgs; [
    fzf gitstatus
  ];
  environment.shellAliases = import ./aliases.nix;
}
