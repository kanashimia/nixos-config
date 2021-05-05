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

  environment.variables = {
    HISTCONTROL = "ignoreboth:erasedups";
  };

  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch -L";
    nrsr = "sudo nixos-rebuild switch -L --rollback";
    nrb = "sudo nixos-rebuild boot -L";
    nrbr = "sudo nixos-rebuild boot -L && reboot";
  
    nfu = "nix flake update";
  
    rdm = "systemctl restart display-manager";
  
    ga = "git add";
    gc = "git commit";
    gp = "git push";
  };
}
