{ pkgs, config, ... }:

let
rofi = self: super: {
  rofi = super.rofi.override {
    theme = pkgs.substituteAll {
      src = ./theme.rasi;
      inherit (config.kanashimia.themes.colors)
        background foreground backgroundBr foregroundBr;
    };
  };
};
in
{
  nixpkgs.overlays = [ rofi ];
}
