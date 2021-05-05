final: prev: {
  haskellPackages = prev.haskellPackages.override {
    overrides = hfinal: hprev: {
      xmonad = let
        src = final.inputs.xmonad;
      in hfinal.callCabal2nix "xmonad" src {};

      xmonad-contrib = let
        src = final.inputs.xmonad-contrib;
      in hfinal.callCabal2nix "xmonad-contrib" src {};
    };
  };
}
