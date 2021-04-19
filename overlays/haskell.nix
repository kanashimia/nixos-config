self: super: {
  haskellPackages = super.haskellPackages.override {
    overrides = hself: hsuper: {
      xmonad = let
        src = super.fetchFromGitHub {
          owner = "xmonad";
          repo = "xmonad";
          rev = "4a0b166998a838d91f002991da82507a2d04d3bb";
          sha256 = "uJClI5qg8N5F02Z1vjhPDjr5t4S9Xx25DQDwo0jsSu4=";
        };
      in hsuper.callCabal2nix "xmonad" src {};

      xmonad-contrib = let
        src = super.fetchFromGitHub {
          owner = "xmonad";
          repo = "xmonad-contrib";
          rev = "8f331d44f11dca21a5dae3fb9e95051938f15f50";
          sha256 = "HeJXGA8c3AgYKaOexPCb+6l/a9ZgHOkd2nZsHm5eig4=";
        };
      in hsuper.callCabal2nix "xmonad-contrib" src {};
    };
  };
}
