{
  nixpkgs.overlays = builtins.map import [
    ./haskell.nix
    ./neofetch.nix
    ./dwl.nix
  ];
}
