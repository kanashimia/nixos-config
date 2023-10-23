{ pkgs, lib, config, ... }: {
  environment.etc."xdg/foot/foot.ini".source = pkgs.substituteAll (
    (lib.mapAttrs (_: lib.removePrefix "#") config.themes.colors) // {
      src = ./foot.ini;
    } 
  );
}
