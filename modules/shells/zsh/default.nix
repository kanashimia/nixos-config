{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    syntaxHighlighting.enable = true;
    interactiveShellInit = builtins.readFile ./zshrc;
    shellInit = "zsh-newuser-install () {}";
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/projects/nixos";
      ns = "nix shell";
      nr = "nix run";
      nd = "nix develop";
      s = "systemctl";
      j = "journalctl --no-hostname -eb -o short-monotonic";
      jw = "j -p notice";
      jf = "j -f";
      jk = "j -k";
      d = "dmesg";
    };
    promptInit = ''
      PS1=$'\n%F{cyan}%~%f\n%(!.!.%F{%(?.green.red)}›)%f'
    '';
  };

  users.defaultUserShell = pkgs.zsh;
}
