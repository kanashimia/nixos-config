{
  description = "Configuration of my nixos machines.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    xmonad-systemd.url = "github:kanashimia/xmonad-systemd";
    agenix.url = "github:ryantm/agenix";
    nix.url = "github:nixos/nix";

    digimend.url = "github:kurikaesu/digimend-kernel-drivers/xppen-artist22r-pro";
    digimend.flake = false;
    xp-pen-userland.url = "github:kurikaesu/xp-pen-userland";
    xp-pen-userland.flake = false;
    evsieve.url = "github:karsmulder/evsieve";
    evsieve.flake = false;
  };
  
  outputs = inputs:  let
    inherit (inputs.nixpkgs) lib;
    nlib = import ./lib.nix { inherit lib inputs; };
  in {
    nixosModules = nlib.mkAttrsTree ./modules;
    overlays = nlib.mkOverlayTree ./overlays;
    nixosConfigurations = nlib.mkNixosConfigs ./hosts;
  };
}
