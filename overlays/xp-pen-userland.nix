inputs: final: prev: {
  xp-pen-userland = final.stdenv.mkDerivation {
    pname = "xp-pen-userland";
    version = "unstable";
    src = inputs.xp-pen-userland;
    patchPhase = ''
      substituteInPlace ./CMakeLists.txt \
        --replace 'VERSION 3.20' 'VERSION 3.19' \
        --replace ${final.lib.escapeShellArgs [
          "\"LICENSE\"" "\"\${CMAKE_CURRENT_SOURCE_DIR}/LICENSE\""
        ]}
    '';
    nativeBuildInputs = [ final.cmake ];
    buildInputs = [ final.libusb ];
    postFixup = ''
      mkdir -p $out/lib
      cp -r $src/config/etc/udev $out/lib
      cp -r $src/config/usr/share $out
    '';
  };
}
