final: prev: {
  dwl = prev.dwl.overrideAttrs (old: rec {
    pname = "dwl";
    version = "0.2.1";
    src = final.fetchFromGitHub {
      owner = "djpohly";
      repo = pname;
      rev = "v${version}";
      sha256 = "lfUAymLA4+E9kULZIueA+9gyVZYgaVS0oTX0LJjsSEs=";
    };
    buildInputs = old.buildInputs ++ [ final.pixman ];
    patches = [ ];
  });
}
