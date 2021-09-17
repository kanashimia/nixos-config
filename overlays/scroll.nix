inputs: final: prev: {
  scroll = final.stdenv.mkDerivation rec {
    pname = "scroll";
    version = "0.1";
  
    src = final.fetchgit {
      url = "https://git.suckless.org/scroll";
      rev = version;
      sha256 = "dr1s1K13BigfGSFvfBuOOy+yhuAcN1fb/4AEZPj9C48=";
    };
  
    nativeBuildInputs = with final; [ pkg-config ];
  
    installPhase = ''
      make install PREFIX=$out
    '';
  };
}
