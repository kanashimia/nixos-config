{ pkgs, config, nixosModules, ... }: {
  imports = with nixosModules; [ themes.colors ];
    
  environment.etc."xdg/alacritty.yml" = {
    source = pkgs.substituteAll (
      config.themes.colors // {
        src = ./alacritty.yml;
      } 
    );
  };
}
