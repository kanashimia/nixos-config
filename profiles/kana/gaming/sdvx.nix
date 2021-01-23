{ pkgs, ...}:

let
sdvx = pkgs.stdenv.mkDerivation rec {
  name = "unnamed-sdvx-clone";

  src = pkgs.fetchFromGitHub {
    repo = "unnamed-sdvx-clone";
    owner = "Drewol";
    rev = "72561c7b9eb3ca9e06f7b001da4deff557ba9187";
    sha256 = "Kkn/mhJn9GKC5f/hD5B5Go+WIzV6/KWYfZsu0YxyVo8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [ cmake ];
  buildInputs = with pkgs; [
    freetype libogg libvorbis SDL2 zlib libpng libjpeg libarchive
    mesa openssl libiconv rapidjson curl
  ];

  patchPhase = ''
    substituteInPlace Main/CMakeLists.txt \
      --replace "target_compile_definitions(usc-game PRIVATE GIT_COMMIT=\''${GIT_DATE_HASH})" "" \
      --replace "-Werror" ""
    substituteInPlace Graphics/CMakeLists.txt \
      --replace "-Werror" ""
    substituteInPlace Audio/CMakeLists.txt \
      --replace "-Werror" ""

    substituteInPlace Shared/src/Path.cpp \
      --replace 'gameDir = ""' 'gameDir = String(getenv("HOME")) + "/.local/share/unnamed-sdvx-clone"'
  '';

  configurePhase = ''
    cmake -DCMAKE_BUILD_TYPE=Release .
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out
    mv bin $out
  '';
};
in
{
    # home.packages = with pkgs; [ sdvx patchelf ];
}
