{ pkgs, ...}:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ./config.fish;
    shellAbbrs = {
      syu = "sudo nixos-rebuild switch -L";
      syr = "sudo nixos-rebuild switch --rollback";
      sys = "nix search nixpkgs";

      ga = "git add .";
      gc = "git commit -m";
      gcl = "git clone";
      gp = "git push";
      gds = "git diff --staged";
    };
  };
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
}
