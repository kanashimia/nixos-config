{ inputs, nixsuper, ... }:

let
unstable = self: super: {
  unstable = inputs.unstable.legacyPackages.${super.system};
};

st = self: super: {
  st = super.st.override {
    extraLibs = [ super.harfbuzz ];
    patches = let
      boxdraw = {
        url = "https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.3.diff";
        sha256 = "a24118148631f6670ea568a3debdd00a7cbcfa525839281888e876e7ea409658";
      };
      ligatures = {
        url = "https://st.suckless.org/patches/ligatures/0.8.3/st-ligatures-boxdraw-20200430-0.8.3.diff";
        sha256 = "cb413a1d2c4102660353dadb1a453f8b708defd9360a16eee1da4e3c3e46ddef";
      };
    in builtins.map super.fetchurl [ boxdraw ligatures ];
  };
};

neofetch = self: super: {
  neofetch = super.neofetch.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "dylanaraps";
      repo = "neofetch";
      rev = "5dfce0f9c3068d4d8a49d0b7182bdace61b8f4d0";
      sha256 = "131r07wllkvrcgw0ndyf5avqpzqkym56ii0qck6qyjfa8ylx6s31";
    };
  });
};

haskellPackages = self: super: {
  haskellPackages = super.haskellPackages.override {
    overrides = hself: hsuper: {
      xmonad-contrib = super.haskell.lib.dontCheck (
        hsuper.callCabal2nix "xmonad-contrib" (
          super.fetchFromGitHub {
            owner = "xmonad";
            repo = "xmonad-contrib";
            rev = "e042bcce9783cb06e4752a4a662106f0cb1084fa";
            sha256 = "eJBOOgvG+/idIwQp0GD4OgQqxA3mfMZ7+IOHhry3mmg=";
          }
        ) {}
      );
    };
  };
};

in
{
  nixpkgs.overlays = [
    st unstable neofetch
  ];
}
