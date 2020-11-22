self: super: {
  xst = super.xst.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ super.harfbuzz ];
    src = super.fetchFromGitHub {
      owner = "arkhan";
      repo = "xst";
      rev = "076796c028369d80e2932438233c8246b98dc35c";
      sha256 = "+qPE4+BRL3QDzUpak22TiiLSqFWd1t/GRWxYuEDwekE=";
    };
    #src = super.fetchFromGitHub {
    #  owner = "gnotclub";
    #  repo = "xst";
    #  rev = "9837593355c15c8bdf607edefda9f72d32098ae3";
    #  sha256 = "nOJcOghtzFkl7B/4XeXptn2TdrGQ4QTKBo+t+9npxOA=";
    #};
  });
}
