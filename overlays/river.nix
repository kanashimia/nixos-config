final: prev: {
  river = prev.river.overrideAttrs (old: {
    installPhase = ''
      runHook preInstall
      zig build -Drelease-safe -Dxwayland -Dman-pages --prefix $out install
      runHook postInstall
    '';
  });
}
