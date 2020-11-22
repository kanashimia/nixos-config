{
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ./config.fish;
    shellAbbrs = {
      syu = "sudo nixos-rebuild switch";
      syr = "sudo nixos-rebuild switch --rollback";
    };
  };
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
}
