{ pkgs, ... }:

let
xst = pkgs.xst.overrideAttrs (old: {
  buildInputs = old.buildInputs ++ [ pkgs.harfbuzz ];
  src = pkgs.fetchFromGitHub {
    owner = "arkhan";
    repo = "xst";
    rev = "076796c028369d80e2932438233c8246b98dc35c";
    sha256 = "+qPE4+BRL3QDzUpak22TiiLSqFWd1t/GRWxYuEDwekE=";
  };
});
in
{
  home.packages = with pkgs; [ xst fira-code ];

  fonts.fontconfig.enable = true;
  
  xresources.properties = {
    "st.font" = "Fira Code:pixelsize=16";
    "st.termname" = "st-256color";
    "st.borderpx" = 6;

    "st.scrollrate" = 2;

    "st.boxdraw" = 0;
    "st.boxdraw_bold" = 0;

    #"st.foreground" = "#d5d5e1";
    #"st.background" = "#292d3e";

    #"st.color0" = "#4e5471";
    #"st.color1" = "#f07178";
    #"st.color2" = "#c3e88d";
    #"st.color3" = "#ffc47c";
    #"st.color4" = "#82aaff";
    #"st.color5" = "#c792ea";
    #"st.color6" = "#89ddff";
    #"st.color7" = "#d5d5e1";

    #"st.color8" = "#676e95";
    #"st.color9" = "#f07178";
    #"st.color10" = "#c3e88d";
    #"st.color11" = "#ffc47c";
    #"st.color12" = "#82aaff";
    #"st.color13" = "#c792ea";
    #"st.color14" = "#89ddff";
    #"st.color15" = "#d5d5e1";
  };
}
