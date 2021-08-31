final: prev: {
  xf86_input_wacom = prev.xf86_input_wacom.overrideAttrs (old: rec {
    name = "xf86-input-wacom";
    version = "0.40.0";

    src = final.fetchFromGitHub {
      owner = "linuxwacom";
      repo = name;
      rev = "${name}-${version}";
      sha256 = "0U4pAB5vsIlBewCBqQ4SLHDrwqtr9nh7knZpXZMkzck=";
    };
  });
}
