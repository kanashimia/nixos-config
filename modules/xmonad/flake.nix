{
  outputs = { self, nixpkgs }: {
    devShell.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      ghc = pkgs.ghc.withPackages (p: with p; [ dbus ]);
    in pkgs.mkShell {
      buildInputs = [
        ghc
      ];
    };
  };
}
