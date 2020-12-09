self: super: {
  neofetch = super.neofetch.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "dylanaraps";
      repo = "neofetch";
      rev = "6dd85d67fc0d4ede9248f2df31b2cd554cca6c2f";
      sha256 = "PZjFF/K7bvPIjGVoGqaoR8pWE6Di/qJVKFNcIz7G8xE=";
    };
  });
}
