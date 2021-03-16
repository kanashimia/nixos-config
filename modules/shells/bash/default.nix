{ pkgs, ... }:

{
  programs.bash.promptInit = pkgs.lib.readFile (pkgs.substituteAll {
    src = ./prompt.sh;
    inherit (pkgs) gitstatus;
  });

  environment.systemPackages = with pkgs; [ fzf ];

  programs.bash.interactiveShellInit = ''
    source ${pkgs.fzf}/share/fzf/key-bindings.bash
  '';

  environment.variables.HISTCONTROL = "ignoreboth:erasedups";

  environment.shellAliases = import ./aliases.nix;
}
