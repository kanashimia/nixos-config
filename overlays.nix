{ inputs, nixpkgs, ... }:

let
unstable = self: pkgs: {
  unstable = inputs.unstable.legacyPackages.${pkgs.system};
};

st = self: pkgs: {
  st = pkgs.st.override {
    extraLibs = [ pkgs.harfbuzz ];
    patches = let
      boxdraw = {
        url = "https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.3.diff";
        sha256 = "a24118148631f6670ea568a3debdd00a7cbcfa525839281888e876e7ea409658";
      };
      ligatures = {
        url = "https://st.suckless.org/patches/ligatures/0.8.3/st-ligatures-boxdraw-20200430-0.8.3.diff";
        sha256 = "cb413a1d2c4102660353dadb1a453f8b708defd9360a16eee1da4e3c3e46ddef";
      };
    in builtins.map pkgs.fetchurl [ boxdraw ligatures ];
  };
};

neofetch = self: pkgs: {
  neofetch = pkgs.neofetch.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "dylanaraps";
      repo = "neofetch";
      rev = "5dfce0f9c3068d4d8a49d0b7182bdace61b8f4d0";
      sha256 = "131r07wllkvrcgw0ndyf5avqpzqkym56ii0qck6qyjfa8ylx6s31";
    };
  });
};

in
{
  nixpkgs.overlays = [
    st unstable neofetch
  ];
}
