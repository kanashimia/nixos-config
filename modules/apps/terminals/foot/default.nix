{ pkgs, lib, config, nixosModules, ... }: {
  imports = with nixosModules; [ themes.colors ];
    
  environment.etc."xdg/foot/foot.ini".source = pkgs.substituteAll (
    (lib.mapAttrs (_: lib.removePrefix "#") config.themes.colors) // {
      src = ./foot.ini;
    } 
  );
}
