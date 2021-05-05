{ pkgs, inputs, config,	 ... }:

let
scroll = pkgs.stdenv.mkDerivation rec {
  pname = "scroll";
  version = "0.1";

  src = pkgs.fetchgit {
    url = "https://git.suckless.org/scroll";
    rev = version;
    sha256 = "dr1s1K13BigfGSFvfBuOOy+yhuAcN1fb/4AEZPj9C48=";
  };

  nativeBuildInputs = with pkgs; [ pkg-config ];

  installPhase = ''
    make install PREFIX=$out
  '';
};
st = final: prev: {
  st = prev.st.override {
    patches = with final; [
      #(fetchpatch {
      #  url = "https://st.suckless.org/patches/xresources/st-xresources-20200604-9ba7ecf.diff";
      #  sha256 = "";
      #})
    ];
    
    conf = builtins.readFile
      (final.substituteAll ({
        src = ./config.h;
        scroll = "${scroll}/bin/scroll";
        font = "Fira Code:size=11";
      } // config.kanashimia.themes.colors) );
  };
};
in
{
  fonts.fonts = with pkgs; [ fira-code ];
  nixpkgs.overlays = [ st ];
  environment.systemPackages = [ pkgs.st scroll ];
}
