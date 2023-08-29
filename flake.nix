{
  description = "Configuration of my nixos machines.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    liquidsfz = { url = "github:swesterfeld/liquidsfz"; flake = false; };
  };

  outputs = inputs:  let
    inherit (inputs.nixpkgs) lib;

    mkNixosSystems = lib.mapAttrs (name: modules: 
      lib.nixosSystem { 
        modules = modules ++ [ {
          networking.hostName = name; 
          nixpkgs.overlays = lib.attrValues inputs.self.overlays;
        } ]; 
        specialArgs = {
          inherit inputs;
        };
      }
    );

    mkOverlays = lib.mapAttrs (name: overlay: 
      (final: prev: { ${name} = overlay final prev; })
    );
  in {
    overlays = mkOverlays {
      liquidsfz = final: prev: final.stdenv.mkDerivation {
        pname = "liquidsfz";
        version = "unstable";

        nativeBuildInputs = with final; [ autoreconfHook pkg-config ];
        buildInputs = with final; [ libsndfile libjack2 readline lv2 ];

        src = inputs.liquidsfz;
      };

      foot = final: prev: let
        desktopEntry  = ''
          [Desktop Entry]
          Type=Application
          Exec=foot
          Icon=foot
          Terminal=false
          Categories=System;TerminalEmulator;
          Keywords=shell;prompt;command;commandline;

          Name=Foot
          GenericName=Terminal
          Comment=A wayland native terminal emulator
          Actions=client;server

          [Desktop Action client]
          Name=Foot Client
          Exec=footclient

          [Desktop Action server]
          Name=Foot Server
          Exec=foot --server
        '';
      in final.symlinkJoin {
        inherit (prev.foot) name;
        paths = [ prev.foot ];
        postBuild = ''
          rm $out/share/applications/*
          echo "${desktopEntry}" > $out/share/applications/foot.desktop
        '';
      };

      mpv = final: prev: final.symlinkJoin {
        inherit (prev.mpv ) name;
        paths = [ prev.mpv ];
        postBuild = let
        in ''
          rm $out/share/applications/umpv.desktop
        '';
      };

      nvtop = final: prev: prev.nvtop-amd.overrideAttrs (old: {
        pname = "nvtop";

        cmakeFlags = with final; [
          "-DBUILD_TESTING=ON"
          "-DUSE_LIBUDEV_OVER_LIBSYSTEMD=ON"
        ];

        nativeBuildInputs = old.nativeBuildInputs ++ [ final.addOpenGLRunpath ];
        postFixup = old.postFixup + ''
          addOpenGLRunpath $out/bin/nvtop
        '';
      });
      
      sway-unwrapped = final: prev: 
        inputs.nixpkgs-wayland.packages.${final.system}.sway-unwrapped;
    };

    nixosConfigurations = mkNixosSystems {
      personal-server = [
        ./machines/personal-server
        ./profiles/qemu-guest.nix
        ./profiles/basic
      ];
      hp-laptop = [
        ./machines/hp-laptop
        ./profiles/graphical
      ];
    };
  };
}
