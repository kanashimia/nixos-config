{ pkgs, ... }:

let
rofi = self: super: {
  rofi = super.rofi.override {
    theme = ./theme.rasi;
  };
};
in
{
  nixpkgs.overlays = [ rofi ];
}
