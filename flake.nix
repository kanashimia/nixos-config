{
  description = "Configuration of my nixos machines.";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs";
    # nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixpkgs-other.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-unstablest.url = "github:nixos/nixpkgs/nixos-unstable-small";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    liquidsfz = { url = "github:swesterfeld/liquidsfz"; flake = false; };

    helix = { url = "github:helix-editor/helix"; };

    haproxy = { url = "github:haproxy/haproxy"; flake = false; };

    # smalloc = { url = "github:zooko/smalloc"; flake = false; };

    # direnv-instant = {
    #   url = "github:Mic92/direnv-instant";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # quickenv = { url = "https://codeberg.org/untitaker/quickenv/archive/main.tar.gz"; flake = false; };

    # headplane = {
    #   url = "github:tale/headplane";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   # inputs.flake-utils.follows = "flake-utils";
    #   inputs.devshell = {};
    #   # inputs.nixpkgs.follows = "nixpkgs";
    # };

    # haproxy-dataplaneapi = { url = "github:haproxytech/dataplaneapi"; flake = false; };
    # envycontrol = { url = "github:bayasdev/envycontrol"; flake = false; };
    # snmalloc = { url = "github:microsoft/snmalloc"; flake = false; };

    # tcmalloc = { url = "github:google/tcmalloc"; flake = false; };
   
    # stalwart = { url = "github:stalwartlabs/stalwart/v0.15.4"; flake = false; };
    # helix = { url = "github:alevinval/helix/issue-2719"; };
    
    # slang = { url = "github:shader-slang/slang"; flake = false; };
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;

    mkNixosSystems = lib.mapAttrs (name: modules:
      lib.nixosSystem {
        modules = modules ++ [{
          networking.hostName = name;
          nixpkgs.overlays = lib.attrValues inputs.self.overlays;
          imports = lib.attrValues inputs.self.nixosModules;
        }];
        specialArgs = {
          inherit inputs;
        };
      }
    );

    # mkNixosSystems = lib.mapAttrs (name: modules:
    #   lib.evalModules {
    #     # specialArgs.modulesPath = "${nixpkgs}/nixos/modules";
    #     modules = modules ++ [
    #       {
    #         networking.hostName = name;
    #         nixpkgs.overlays = lib.attrValues inputs.self.overlays;
    #         imports = lib.attrValues inputs.self.nixosModules;
    #       }
    #       (import ./module-list.nix { nixpkgs = inputs.nixpkgs; lib = lib; })
    #       {
    #         _module.args = {
    #           inputs = inputs;
    #           # baseModules = (import ./module-list.nix { nixpkgs = inputs.nixpkgs; lib = lib; });
    #         };
    #       }
    #     ];
    #   }
    # );

    mkOverlays = lib.mapAttrs (name: overlay:
      (final: prev: { ${name} = overlay final prev; })
    );

    mkNixosModules = lib.mapAttrs (name: path: import path);
  in {
    # foo = builtins.concatStringsSep "\n\n" (
    #   map (x: x.file + "\n" + builtins.concatStringsSep "\n" (map (s: "  " + s) x.value) )
    #     inputs.self.nixosConfigurations.hp-laptop.options.environment.systemPackages.definitionsWithLocations
    # );

    overlays = mkOverlays {
      system = final: prev: final.stdenv.hostPlatform.system;

      # zsh = final: prev: prev.zsh.overrideAttrs (old: {
      #   buildInputs = old.buildInputs ++ [
      #     final.gdbm
      #   ]; 
      #   configureFlags = old.configureFlags ++ [
      #     "--enable-gdbm"
      #   ];
      # });

      # security patches
      # nix = final: prev: inputs.nixpkgs-small.legacyPackages.${final.system}.nix;
      # lix = final: prev: inputs.nixpkgs-small.legacyPackages.${final.system}.lix;
      # nixVersions = final: prev: inputs.nixpkgs-small.legacyPackages.${final.system}.nixVersions;
      # lixVersions = final: prev: inputs.nixpkgs-small.legacyPackages.${final.system}.lixVersions;

      # chromium = final: prev:
      #   inputs.nixpkgs-unstablest.legacyPackages.${final.system}.chromium;

      # sfizz = final: prev: with final; stdenv.mkDerivation {
      #   pname = "sfizz-ui";
      #   version = "1.2.3a";
      #   src = fetchFromGitHub {
      #     owner = "sfztools";
      #     repo = "sfizz-ui";
      #     rev = "93da042624117da7c722a237d540a058cb629df0";
      #     hash = "sha256-LuxgMP97+VcYaWNF1315wot099+khShgqjOTQG3WyjU=";
      #     fetchSubmodules = true;
      #   };
      #   buildInputs = [
      #     libjack2
      #     libsndfile
      #     flac
      #     libogg
      #     libvorbis
      #     libopus
      #     libX11
      #     libxcb
      #     libXau
      #     libXdmcp
      #     xcbutil
      #     xcbutilcursor
      #     xcbutilrenderutil
      #     xcbutilkeysyms
      #     xcbutilimage
      #     libxkbcommon
      #     cairo
      #     glib
      #     freetype
      #     pango
      #     zenity
      #   ];
      #   nativeBuildInputs = [ cmake pkg-config ];
      #   postPatch = ''
      #     substituteInPlace plugins/editor/src/editor/NativeHelpers.cpp \
      #       --replace-fail 'auto glibPath = g_find_program_in_path("zenity");' \
      #       'auto glibPath = g_strdup("${zenity}/bin/zenity");'
      #     substituteInPlace plugins/editor/external/vstgui4/vstgui/lib/platform/linux/x11fileselector.cpp \
      #       --replace-fail 'zenitypath = "zenity"' \
      #       'zenitypath = "${zenity}/bin/zenity"'
      #   '';
      # };

      helix = final: prev: (
        inputs.helix.packages.${final.system}.helix
      );

      sway-assign-cgroups = final: prev: prev.sway-assign-cgroups.overrideAttrs {
        postPatch = ''
          substituteInPlace ./src/assign-cgroups.py \
            --replace-fail 'if self.cgroup_change_needed(cgroup):' 'if True:'
        '';
      };

      # qemu-new = final: prev: prev.qemu.overrideAttrs (old: rec {
      #   version = "9.2.0";
      #   src = final.fetchurl {
      #     url = "https://download.qemu.org/qemu-${version}.tar.xz";
      #     hash = "sha256-+FnwvGXh9TPQQLvoySvP7O5a8skhpmh8ZS+0TQib2JQ=";
      #   };
      #   patches = lib.filter (x: ! lib.elem (baseNameOf x) [
      #     "fix-qemu-ga.patch"
      #     "xfk3xqxdz4ibi209b25d6ir9jp5nmybj-ac1bbe8ca46c550b3ad99c85744119a3ace7b4f4.diff"
      #     "b83md1mbr85n7mk3jyagimn91k3457md-99174ce39e86ec6aea7bb7ce326b16e3eed9e3da.diff"
      #   ]) old.patches;
      # });

      # mesa-demos = final: prev: prev.mesa-demos.overrideAttrs (old: rec {
      #   mesonFlags = [
      #     "-Dosmesa=disabled"
      #     "-Dwith-system-data-files=true"
      #   ];
      # });

      # mypaint = final: prev: (
      #   prev.mypaint.overrideAttrs (old: {
      #     doInstallCheck = false;
      #     checkPhase = null;
      #   })
      # );

      # openobserve = final: prev: (
      #   prev.openobserve.override {
      #     rustPlatform = final.rustPlatform // {
      #       buildRustPackage = args: final.rustPlatform.buildRustPackage (args // rec {
      #         src = inputs.openobserve;
      #         cargoLock.lockFile = "${src}/Cargo.lock";
      #         cargoLock.outputHashes = {
      #           "chromiumoxide-0.5.7" = "sha256-GHrm5u8FtXRUjSRGMU4PNU6AJZ5W2KcgfZY1c/CBVYA=";
      #           "enrichment-0.1.0" = "sha256-FDPSCBkx+DPeWwTBz9+ORcbbiSBC2a8tJaay9Pxwz4w=";
      #         };
      #         doCheck = false;
      #       });
      #     };
      #     buildNpmPackage = args: final.buildNpmPackage (args // {
      #       src = inputs.openobserve;
      #       sourceRoot = "source/web";
      #       npmDeps = final.importNpmLock {
      #         npmRoot = "${inputs.openobserve}/web";
      #       };
      #       npmConfigHook = final.importNpmLock.npmConfigHook;
      #     });
      #   }
      # );

      # caddyWith = final: prev: with final; (
      #   { plugins, vendorHash, caddyRev ? caddy.src.rev }: (
      #     caddy.override {
      #       buildGoModule = args: buildGoModule (args // {
      #         src = stdenv.mkDerivation {
      #           pname = "caddy-using-xcaddy-${xcaddy.version}";
      #           inherit (caddy) version;

      #           dontUnpack = true;
      #           dontFixup = true;

      #           nativeBuildInputs = [
      #             cacert
      #             go
      #           ];

      #           configurePhase = ''
      #             export GOCACHE="$TMPDIR/go-cache"
      #             export GOPATH="$TMPDIR/go"
      #             export XCADDY_SKIP_BUILD=1
      #           '';

      #           buildPhase = ''
      #             ${lib.getExe xcaddy} build "${caddyRev}" \
      #               ${lib.concatMapStringsSep " " ({ src, rev }: "--with ${src}@${rev}") plugins}
      #             cd buildenv*
      #             go mod vendor
      #           '';

      #           installPhase = ''
      #             cp -r . "$out"
      #           '';

      #           outputHash = vendorHash;
      #           outputHashMode = "recursive";
      #           outputHashAlgo = if vendorHash == "" then "sha256" else null;
      #         };

      #         subPackages = [ "." ];
      #         ldflags = [ "-s" "-w" ]; ## don't include version info twice
      #         vendorHash = null;
      #       });
      #     }
      #   )
      # );

      # stalwart-mail = final: prev: prev.stalwart-mail.overrideAttrs (old: {
      #   prePatch = ''
      #     cat <<EOF > Cargo.toml
      #     [workspace]
      #     resolver = "2"
      #     members = [
      #         "crates/main",
      #         "crates/jmap",
      #         "crates/jmap-proto",
      #         "crates/imap",
      #         "crates/imap-proto",
      #         "crates/smtp",
      #         "crates/managesieve",
      #         "crates/pop3",
      #         "crates/nlp",
      #         "crates/store",
      #         "crates/directory",
      #         "crates/utils",
      #         "crates/common",
      #         "crates/trc",
      #         "crates/cli",
      #         # "tests",
      #     ]
      #     EOF
      #   '';
      #   doCheck = false;
      # });

      # stalwart_0_16 = final: prev: prev.stalwart_0_16.overrideAttrs (old: {
      #   cargoPatches = [
      #     ./stalwart-tikv-je.patch
      #   ];
      #   cargoHash = "";
      #   prePatch = ''
      #     substituteInPlace ./Cargo.toml --replace-fail \
      #       '"tests",' ""
      #     substituteInPlace ./crates/main/src/main.rs --replace-fail \
      #       'jemallocator' 'tikv_jemallocator'
      #     substituteInPlace ./tests/src/lib.rs --replace-fail \
      #       'jemallocator' 'tikv_jemallocator'
      #     substituteInPlace ./crates/main/Cargo.toml --replace-fail \
      #       'jemallocator = "0.5.0"' 'tikv-jemallocator = "0.7.0"'
      #     substituteInPlace ./tests/Cargo.toml --replace-fail \
      #       'jemallocator = "0.5.0"' 'tikv-jemallocator = "0.7.0"'
      #     substituteInPlace ./crates/store/Cargo.toml --replace-fail \
      #       '["multi-threaded-cf"]' '["multi-threaded-cf", "jemalloc"]'
      #     substituteInPlace ./Cargo.toml --replace-fail \
      #       'codegen-units = 1' ""
      #     substituteInPlace ./Cargo.toml --replace-fail \
      #       'lto = true' ""
      #     substituteInPlace ./Cargo.toml --replace-fail \
      #       'opt-level = 3' "opt-level = 2"
      #   '';
      #   doCheck = false;
      # });

      /*
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
          foundationdb
        ];

        env = {
          OPENSSL_NO_VENDOR = true;
          ZSTD_SYS_USE_PKG_CONFIG = true;
        };

        doCheck = false;

        meta.mainProgram = "stalwart-mail";
      };
      */

      liquidsfz = final: prev: final.stdenv.mkDerivation rec {
        pname = "liquidsfz";
        version = "0.unstable-${src.shortRev}";

        src = inputs.liquidsfz;

        nativeBuildInputs = with final; [
          autoreconfHook pkg-config autoconf-archive
        ];

        buildInputs = with final; [
          libsndfile libjack2 readline lv2
          libglvnd libx11 libxext libxrandr libxcursor
          fftw fftwFloat
        ];

        postPatch = ''
          # hardcodes path
          substituteInPlace lv2/lv2ui.cc --replace-fail \
            '/usr/bin/zenity' '${final.lib.getExe final.zenity}'

          # use our copy of imgui
          rmdir 3rdparty/imgui
          ln -T -s ${final.imgui.src} 3rdparty/imgui
        '';

        configureFlags = [ "--with-fftw" ];
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
        # foot = prev.foot.overrideAttrs (old: {
        #   src = final.fetchFromGitea {
        #     domain = "codeberg.org";
        #     owner = "dnkl";
        #     repo = "foot";
        #     rev = "64e7f2512481d33fb46b1cd3eff4b4854d634a2c";
        #     hash = "sha256-aT65k+hez06gx+zWdvAGpKdfdzP5DodrI1KVw3TmlC4=";
        #   };
        # });
      in final.symlinkJoin {
        inherit (prev.foot) name;
        paths = [ prev.foot ];
        postBuild = ''
          rm $out/share/applications/*
          echo "${desktopEntry}" > $out/share/applications/foot.desktop
        '';
        meta = prev.foot.meta;
      };

      # mpv-unwrapped = final: prev: prev.mpv-unwrapped.override {
      #   ffmpeg = final.ffmpeg-full;
      # };

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

        nativeBuildInputs = old.nativeBuildInputs ++ [ final.addDriverRunpath ];
        postFixup = old.postFixup + ''
          addDriverRunpath $out/bin/nvtop
        '';
      });

      # envycontrol = final: prev: final.python3Packages.buildPythonPackage {
      #   pname = "envycontrol";
      #   version = "0.unstable";
      #   src = inputs.envycontrol;
      #   pyproject = true;
      #   build-system = [ final.python3Packages.setuptools ];
      # };

      # musescore = final: prev: prev.musescore.overrideAttrs (old: {
      #   src = final.fetchFromGitHub {
      #     owner = "musescore";
      #     repo = "MuseScore";
      #     rev = "e0ed76d4e5bce38df5cb30e27a7c9a6f65990125";
      #     sha256 = "sha256-niCsWzN5cV49O+Mds0Mz13OyeEFZ+sfk0MbPeit0NUs=";
      #   };
      #   patches = [];
      # });

      quickenv = final: prev: final.rustPlatform.buildRustPackage rec {
        pname = "quickenv";
        version = "0.unstable-${src.shortRev}";
        # version = "unstable";
        src = inputs.quickenv;
        cargoLock.lockFile = "${src}/Cargo.lock";
        doCheck = false;
        postPatch = ''
          substituteInPlace src/main.rs \
            --replace-fail 'io::stdout().write_all(v.as_bytes())?;' \
            ${lib.escapeShellArg ''io::stdout().write_all(b"'")?; io::stdout().write_all(v.into_string().unwrap().replace('\''', r"'\'''").as_bytes())?; io::stdout().write_all(b"'")?;''}
        '';
      };

      # sway-unwrapped = final: prev:
      #   inputs.nixpkgs-wayland.packages.${final.system}.sway-unwrapped.overrideAttrs (old: {
      #     patches = old.patches ++ [
      #       (final.fetchpatch {
      #         url = "https://github.com/swaywm/sway/compare/055be4ec35eec4eaaf066a18ccbf5132ebed0694..2f776c50d117753e9a40f4ea8918491f295f6087.diff";
      #         sha256 = "sha256-qnbMCR/7Gf2bLKEWFpywKli8aZyJtq0hQapQOncWdKA=";
      #       })
      #     ];
      #   });

      sway-unwrapped = final: prev:
        inputs.nixpkgs-wayland.packages.${final.system}.sway-unwrapped.overrideAttrs (old: {
          postPatch = ''
            substituteInPlace ./sway/tree/container.c --replace-fail \
              'if (config->pango_markup)' \
              'if (false)'
          '';
        });
      swaybg = final: prev:
        inputs.nixpkgs-wayland.packages.${final.system}.swaybg;
      xdg-desktop-portal-wlr = final: prev:
        inputs.nixpkgs-wayland.packages.${final.system}.xdg-desktop-portal-wlr;

      # direnv-instant = final: prev:
      #   inputs.direnv-instant.packages.${final.system}.default;

      haproxy = final: prev:
        (prev.haproxy.override {
          sslLibrary = "aws-lc";
          zlib = final.zlib-ng.override { withZlibCompat = true; };
        })
        # prev.haproxy
          .overrideAttrs (old: rec {
            version = "0.unstable-${src.shortRev}";
            src = inputs.haproxy;
            # patches = [ ./haproxy-ca-store.patch ]; 
            postPatch = ''
              substituteInPlace src/errors.c \
                --replace-fail \
                  'memprintf(&head, "%s (%u) : ", prefix, (uint)getpid());' \
                  'memprintf(&head, "%s", label);' \
                --replace-fail '"NOTICE"' '"<5>"' \
                --replace-fail '"WARNING"' '"<4>"' \
                --replace-fail '"ALERT"' '"<1>"' \
                --replace-fail '"DIAG"' '"<4>"'
            '';
          })
        ;
      haproxy-dataplaneapi = final: prev: final.buildGoModule rec {
        pname = "haproxy-dataplaneapi";
        version = "0.unstable-${src.shortRev}";
        src = inputs.haproxy-dataplaneapi;
        vendorHash = "sha256-jnFxZywYDThBh/hr9WUyaYBBBDf2Lgkw42hXCflmlXE=";
        subPackages = [
          "cmd/dataplaneapi"
        ];
      };

      snmalloc = final: prev: with final; stdenv.mkDerivation rec {
        pname = "snmalloc";
        version = "0.unstable-${src.shortRev}";
        src = inputs.snmalloc;

        nativeBuildInputs = [ cmake ninja ];

        cmakeFlags = [
          # "-DMI_INSTALL_TOPLEVEL=ON"
        ]
        # ++ lib.optionals secureBuild [ "-DMI_SECURE=ON" ]
        # ++ lib.optionals stdenv.hostPlatform.isStatic [ "-DMI_BUILD_SHARED=OFF" ]
        ++ lib.optionals (!doCheck) [ "-DSNMALLOC_BUILD_TESTING=OFF" ]
        ;

        doCheck = false;

        # postPatch = ''
        #   substituteInPlace
        # '';

        # postInstall =
        #   let
        #     rel = lib.versions.majorMinor version;
        #     suffix = if stdenv.hostPlatform.isLinux then "${soext}.${rel}" else ".${rel}${soext}";
        #   in
        #   ''
        #     # first, move headers and cmake files, that's easy
        #     mkdir -p $dev/lib
        #     mv $out/lib/cmake $dev/lib/
        #     find $dev $out -type f
        #   ''
        #   + (lib.optionalString secureBuild ''
        #     # pretend we're normal mimalloc
        #     ln -sfv $out/lib/libmimalloc-secure${suffix} $out/lib/libmimalloc${suffix}
        #     ln -sfv $out/lib/libmimalloc-secure${suffix} $out/lib/libmimalloc${soext}
        #     ln -sfv $out/lib/libmimalloc-secure.a $out/lib/libmimalloc.a
        #     ln -sfv $out/lib/mimalloc-secure.o $out/lib/mimalloc.o
        #   '');

        outputs = [ "out" "dev" ];
      };

      smalloc = final: prev: with final; rustPlatform.buildRustPackage rec {
        pname = "smalloc";
        version = "0.unstable-${src.shortRev}";
        src = inputs.smalloc;
        cargoLock.lockFile = "${src}/Cargo.lock";

        nativeBuildInputs = [ ];

        patchPhase = ''
          substituteInPlace smalloc-ffi/src/lib.rs \
            --replace-fail 'UNUSED_SC_MASK' '0b111'
        '';

        cargoBuildFlags = [
          "-p smalloc-ffi"
        ];

        doCheck = false;
      };

      # mimalloc = final: prev: prev.mimalloc.overrideAttrs (old: rec {
      #   version = "2.2.4";
      #   src = final.fetchFromGitHub {
      #     owner = "microsoft";
      #     repo = "mimalloc";
      #     rev = "v${version}";
      #     sha256 = "sha256-+8xZT+mVEqlqabQc+1buVH/X6FZxvCd0rWMyjPu9i4o=";
      #   };
      # });

      # tcmalloc = final: prev: final.stdenv.mkDerivation rec {
      #   pname = "tcmalloc";
      #   version = "0.unstable-${src.shortRev}";
      #   src = inputs.tcmalloc;
      #   bazel = final.bazel_7;
      #   nativeBuildInputs = [ final.cmake ];
      #   patches = [
      #     (final.fetchpatch {
      #       url = "https://patch-diff.githubusercontent.com/raw/google/tcmalloc/pull/104.patch";
      #       hash = "sha256-UJMS6HJTFzQ7uwFNl+A3b37SGMvTIYqBi7IFBZN7gnY=";
      #     })
      #   ];
      # };

      # tcmalloc = final: prev: final.buildBazelPackage rec {
      #   pname = "tcmalloc";
      #   version = "0.unstable-${src.shortRev}";
      #   src = inputs.tcmalloc;
      #   bazel = final.bazel_7;
      #   fetchAttrs = {
      #     hash = "";
      #   };
      #   buildAttrs = {};
      #   # buildAttrs.installPhase = ''
      #   # '';
      #   # buildAttrs.installPhase = ''
      #   #   runHook preInstall
      #   #   # unzip bazel-bin/unix/mozc.zip -x "tmp/*" -d /
      #   #   # # create a desktop file for gnome-control-center
      #   #   # # copied from ubuntu
      #   #   # mkdir -p $out/share/applications
      #   #   # cp ${./ibus-setup-mozc-jp.desktop} $out/share/applications/ibus-setup-mozc-jp.desktop
      #   #   # substituteInPlace $out/share/applications/ibus-setup-mozc-jp.desktop \
      #   #   #   --replace-fail "@mozc@" "$out"
      #   #   runHook postInstall
      #   # '';
      # };


      # sway-scroll = final: prev:
      #   final.sway-unwrapped.overrideAttrs (old: {
      #     src = final.fetchFromGitHub {
      #       owner = "dawsers";
      #       repo = "scroll";
      #       rev = "f4272c637dd827b1b708412a413f92524fbfca31";
      #       sha256 = "sha256-2SwZ8XtnCOOKNA7FpzcKGgHTB7Xnxtgr00x9Zk4EerI=";
      #     };
      #     mesonFlags = [ "-Dwerror=false" "-Dsd-bus-provider=libsystemd" ];
      #   });
    } // {
      # headplane = inputs.headplane.overlays.default;
    };

    nixosModules = mkNixosModules {
      unfree = ./modules/unfree.nix;
      terraria = ./modules/terraria.nix;
      stalwart-mail = ./modules/stalwart-mail.nix;
      stalwart = ./modules/stalwart.nix;
    } // {
      # headplane = inputs.headplane.nixosModules.headplane;
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
