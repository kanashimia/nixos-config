{ pkgs, ... }:

let
xst = self: super: {
  xst = super.xst.overrideAttrs (old: rec {
    version = "0.8.4.1";
    src = super.fetchFromGitHub {
      owner = "gnotclub";
      repo = "xst";
      rev = "v${version}";
      sha256 = "nOJcOghtzFkl7B/4XeXptn2TdrGQ4QTKBo+t+9npxOA=";
    };
  });
};
config = pkgs.writeText "config" ''
  st.font: Fira Code:pixelsize=14
  st.borderpx: 6
  st.scrollrate: 2
  st.boxdraw: 1
  st.boxdraw_bold: 1
  st.boxdraw_braille: 1
'';
in
{
  nixpkgs.overlays = [ xst ];
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge ${config}
  '';
  fonts.fonts = with pkgs; [ fira-code ];
}
