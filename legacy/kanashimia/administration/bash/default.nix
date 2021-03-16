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
    source ${pkgs.fzf}/share/fzf/completion.bash
    source ${pkgs.fzf}/share/fzf/key-bindings.bash

    export HISTCONTROL=ignoreboth:erasedups
  '';
  environment.systemPackages = with pkgs; [
    fzf
  ];
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch -L";
    nrsr = "sudo nixos-rebuild switch -L --rollback";
    nrb = "sudo nixos-rebuild boot -L && reboot";
    rdm = "systemctl restart display-manager";
  };
}
