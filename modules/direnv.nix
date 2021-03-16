{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ direnv ];
  # nix.extraOptions = ''
  #   keep-outputs = true
  #   keep-derivations = true
  # '';
  environment.variables.DIRENV_CONFIG = ''
    ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
  '';
  
  programs.bash.interactiveShellInit = ''
    eval "$(${pkgs.direnv}/bin/direnv hook bash)"
  '';
  programs.zsh.interactiveShellInit = ''
    eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
  '';
  programs.fish.interactiveShellInit = ''
    ${pkgs.direnv}/bin/direnv hook fish | source
  '';
}
