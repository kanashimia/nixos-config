{ pkgs, ...}:

{
  programs.fish = {
    enable = true;
    package = pkgs.fish.override {
      useOperatingSystemEtc = false;
    };
    interactiveShellInit = (builtins.readFile ./config.fish) + ''
      set -l prev (string join0 $fish_complete_path | string match --regex "^.*?(?=\x00[^\x00]*generated_completions.*)" | string split0 | string match -er ".")
      set -l post (string join0 $fish_complete_path | string match --regex "[^\x00]*generated_completions.*" | string split0 | string match -er ".")
      set fish_complete_path $prev "/etc/fish/generated_completions" $post
    '';
    shellAbbrs = {
      syu = "sudo nixos-rebuild switch";
      syr = "sudo nixos-rebuild switch --rollback";
      sys = "nix search nixpkgs";
    };
  };
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
}
