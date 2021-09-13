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
      xp-pen-userland = final: prev: {
        xp-pen-userland = final.stdenv.mkDerivation {
          pname = "xp-pen-userland";
          version = "unstable";
          src = inputs.xp-pen-userland;
          patchPhase = ''
            substituteInPlace ./CMakeLists.txt \
              --replace 'VERSION 3.20' 'VERSION 3.19' \
              --replace 'LICENSE' '\''${CMAKE_CURRENT_SOURCE_DIR}/LICENSE'
          '';
          nativeBuildInputs = [ final.cmake ];
          buildInputs = [ final.libusb ];
          postFixup = ''
            mkdir -p $out/lib
            cp -r $src/config/etc/udev $out/lib
            cp -r $src/config/usr/share $out
          '';
        };
      };
    };
     
    nixosConfigurations = nlib.mkNixosConfigurations {
      system = "x86_64-linux";
      overlays = with inputs; [
        xmonad-systemd.overlay
        self.overlays.digimend
        self.overlays.xp-pen-userland
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
