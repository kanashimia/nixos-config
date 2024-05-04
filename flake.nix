{
  description = "Configuration of my nixos machines.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    liquidsfz = { url = "github:swesterfeld/liquidsfz"; flake = false; };
    stalwart = { url = "github:stalwartlabs/mail-server"; flake = false; };
    caddy = { url = "github:caddyserver/caddy"; flake = false; };
    cypht = { url = "github:cypht-org/cypht"; flake = false; };
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;

    mkNixosSystems = lib.mapAttrs (name: modules:
      lib.nixosSystem {
        modules = modules ++ [{
          networking.hostName = name;
          nixpkgs.overlays = lib.attrValues inputs.self.overlays;
        }];
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
      cypht = final: prev: final.php.buildComposerProject (finalAttrs: {
        pname = "cypht";
        version = "2.0.0";

        src = inputs.cypht;

        php = final.php.withExtensions ({ enabled, all }:
          enabled ++ [ all.openssl all.curl ]);

        vendorHash = "sha256-DtQDl3O6pB4gm8HfZFmTknEgYTt0O775B4ocIau0n2k=";

        installPhase = ''
          runHook preInstall

          mv $out/share/php/cypht/* $out
          rm -r $out/share

          touch $out/.env
          cd $out
          php ./scripts/config_gen.php

          runHook postInstall
        '';

        postFixup = ''
          substituteInPlace $out/index.php --replace-fail \
            "define('APP_PATH', ''')" \
            "define('APP_PATH', '$out/')"
        '';

        # Upstream composer.json file is missing the name, description and license fields
        composerStrictValidation = false;
      });

      caddyWith = final: prev:
        { plugins, vendorHash, caddyRev ? inputs.caddy.rev }: with final;
          caddy.override {
            buildGoModule = args: buildGoModule (args // {
            src = stdenv.mkDerivation {
              pname = "caddy-using-xcaddy-${xcaddy.version}";
              inherit (caddy) version;

              dontUnpack = true;
              dontFixup = true;

              nativeBuildInputs = [
                cacert
                go
              ];

              configurePhase = ''
                export GOCACHE="$TMPDIR/go-cache"
                export GOPATH="$TMPDIR/go"
                export XCADDY_SKIP_BUILD=1
              '';

              buildPhase = ''
                ${lib.getExe xcaddy} build "${caddyRev}" \
                  ${lib.concatMapStringsSep " " (plugin: "--with ${plugin}") plugins}
                cd buildenv*
                go mod vendor
              '';

              installPhase = ''
                cp -r . "$out"
              '';

              outputHash = vendorHash;
              outputHashMode = "recursive";
              outputHashAlgo = if vendorHash == "" then "sha256" else null;
            };

            subPackages = [ "." ];
            ldflags = [ "-s" "-w" ]; ## don't include version info twice
            vendorHash = null;
          });
        };

      stalwart-mail = final: prev: final.rustPlatform.buildRustPackage rec {
        pname = "stalwart-mail";
        version = "unstable";

        src = inputs.stalwart;

        cargoLock.lockFile = "${src}/Cargo.lock";

        nativeBuildInputs = with final; [
          pkg-config
          protobuf
          rustPlatform.bindgenHook
        ];

        buildInputs = with final; [
          bzip2
          openssl
          sqlite
          zstd
        ];

        env = {
          OPENSSL_NO_VENDOR = true;
          ZSTD_SYS_USE_PKG_CONFIG = true;
          # ROCKSDB_INCLUDE_DIR = "${final.rocksdb}/include";
          # ROCKSDB_LIB_DIR = "${final.rocksdb}/lib";
        };

        doCheck = false;

        meta.mainProgram = "stalwart-mail";
      };

      liquidsfz = final: prev: final.stdenv.mkDerivation {
        pname = "liquidsfz";
        version = "unstable";

        nativeBuildInputs = with final; [ autoreconfHook pkg-config ];
        buildInputs = with final; [ libsndfile libjack2 readline lv2 ];

        src = inputs.liquidsfz;
      };

      foot = final: prev: let
        desktopEntry = /*ini*/''
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

      mpv-unwrapped = final: prev: prev.mpv-unwrapped.override {
        ffmpeg = final.ffmpeg-full;
      };

      mpv = final: prev: final.symlinkJoin {
        inherit (prev.mpv) name;
        paths = [ prev.mpv ];
        postBuild = ''
          rm $out/share/applications/umpv.desktop
        '';
      };

      nvtop = final: prev: prev.nvtopPackages.amd.overrideAttrs (old: {
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
        ./profiles/basic
      ];
      hp-laptop = [
        ./machines/hp-laptop
        ./profiles/graphical
      ];
    };
  };
}
