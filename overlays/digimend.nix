final: prev: {
  linuxPackages = prev.linuxPackages.extend (lnxfinal: lnxprev: {
    digimend = lnxprev.digimend.overrideAttrs (old: {
      src = final.fetchFromGitHub {
        owner = "digimend";
        repo = "digimend-kernel-drivers";
        rev = "da74089600d6fa7d9ccedcf94c5ba5cfa9adaa8f";
        sha256 = "sha256-0Vgsfqxz0vIywARIeOgVyTA7JJgtq3lm9sPnQ/mx5vU=";
      };
      patches = [];
    });
  });
}
