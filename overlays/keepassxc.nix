final: prev: {
  keepassxc = prev.keepassxc.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ final.readline ];
  });
}
