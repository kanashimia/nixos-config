{
  description = "Configuration of my nixos machines.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    xmonad-systemd.url = "github:kanashimia/xmonad-systemd";
    agenix.url = "github:ryantm/agenix";

    digimend.url = "github:kurikaesu/digimend-kernel-drivers/xppen-artist22r-pro";
    digimend.flake = false;
    xp-pen-userland.url = "github:kurikaesu/xp-pen-userland";
    xp-pen-userland.flake = false;
  };
  
  outputs = inputs:  let
    inherit (inputs.nixpkgs) lib;
    nlib = import ./lib.nix { inherit lib inputs; };
  in {
    nixosModules = nlib.mkAttrsTree ./modules;

    overlays = nlib.mkOverlayTree ./overlays;
     
    nixosConfigurations = nlib.mkNixosConfigs {
      system = "x86_64-linux";
      overlays = with inputs; [
        xmonad-systemd.overlay
        self.overlays.digimend
        self.overlays.xp-pen-userland
        self.overlays.pentablet-driver
      ];
    } {
      ati-workstation = {};
      hp-laptop = {};
      personal-server = {
        modules = with inputs; [
          agenix.nixosModules.age
          mailserver.nixosModule
        ];
      };
    };
  };
}
