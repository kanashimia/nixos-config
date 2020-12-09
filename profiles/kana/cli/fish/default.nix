{ pkgs, ...}:

{
  programs.starship = {
    enable = false;
    package = pkgs.unstable.starship;
  settings = {
    character = rec {
      success_symbol = "[›](bold green)";
      error_symbol = "[›](bold red)";
      vicmd_symbol = "[›](bold blues)";
      format = "$symbol";
    };
  };
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = (builtins.readFile ./config.fish) + ''
      set -l prev (string join0 $fish_complete_path | string match --regex "^.*?(?=\x00[^\x00]*generated_completions.*)" | string split0 | string match -er ".")
      set -l post (string join0 $fish_complete_path | string match --regex "[^\x00]*generated_completions.*" | string split0 | string match -er ".")
      set fish_complete_path $prev "/etc/fish/generated_completions" $post
    '';
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
