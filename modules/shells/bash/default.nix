{ pkgs, ... }:

{
  programs.bash.promptInit = pkgs.lib.readFile (pkgs.substituteAll {
    src = ./prompt.sh;
    gitstatus = "${pkgs.gitstatus}/gitstatus.plugin.sh";
  });

  environment.systemPackages = with pkgs; [ gitstatus fzf ];

  programs.bash.interactiveShellInit = ''
    source ${pkgs.fzf}/share/fzf/key-bindings.bash
  '';

  environment.variables.HISTCONTROL = "ignoreboth:erasedups";

  environment.shellAliases = import ./aliases.nix;
}
