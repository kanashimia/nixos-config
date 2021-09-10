{
  description = "Configuration of my nixos machines.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    xmonad-systemd.url = "github:kanashimia/xmonad-systemd";
    agenix.url = "github:ryantm/agenix";
    digimend.url = "github:kurikaesu/digimend-kernel-drivers/xppen-artist22r-pro";
    digimend.flake = false;
  };
  
  outputs = inputs:  let
    inherit (inputs.nixpkgs) lib;
    nlib = import ./lib.nix { inherit lib inputs; };
  in {
    nixosModules = nlib.mkAttrsetTreeOfModules ./modules;

    overlays = {
      digimend = final: prev: {
        linuxPackagesFor = kernel:
          (prev.linuxPackagesFor kernel).extend (lnxfinal: lnxprev: {
            digimend = lnxprev.digimend.overrideAttrs (old: {
              src = inputs.digimend;
              patches = [];
            });
          });
      };
    };
     
    nixosConfigurations = nlib.mkNixosConfigurations {
      system = "x86_64-linux";
      overlays = with inputs; [
        xmonad-systemd.overlay
        self.overlays.digimend
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
