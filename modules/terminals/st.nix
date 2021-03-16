{ pkgs, inputs, ... }:

let
scroll = pkgs.stdenv.mkDerivation rec {
  pname = "scroll";
  version = "unstable";

  src = inputs.scroll;

  nativeBuildInputs = with pkgs; [ pkg-config ];

  installPhase = ''
    make install PREFIX=$out
  '';
};
in
{
  environment.systemPackages = with pkgs; [ scroll st ];
}
