inputs: final: prev: {
 pentablet-driver = prev.pentablet-driver.overrideAttrs (old: rec {
   version = "3.2.0.210824-1";
   src = final.fetchurl {
     url = "https://download01.xp-pen.com/file/2021/08/XP-PEN-pentablet-${version}.x86_64.tar.gz";
     sha256 = "sha256-JPqeBkMsODt/ddiX/BF4b36FG+F5BhULMK4oVr6jG8g=";
   };
   installPhase = ''
     mkdir -p $out/bin
     cp -R App/usr/lib/pentablet/* $out/bin
     cp -R App/lib $out
     rm -rf $out/bin/lib
   '';
   buildInputs = old.buildInputs ++ [ final.qt5Full ];
 });
}
