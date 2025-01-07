{
  description = "Configuration of my nixos machines.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    liquidsfz = { url = "github:swesterfeld/liquidsfz"; flake = false; };
    # stalwart = { url = "github:stalwartlabs/mail-server/v0.10.4"; flake = false; };
    helix = { url = "github:alevinval/helix/issue-2719"; };
    slang = { url = "github:shader-slang/slang"; flake = false; };
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

    mkOverlays = lib.mapAttrs (name: overlay:
      (final: prev: { ${name} = overlay final prev; })
    );

    mkNixosModules = lib.mapAttrs (name: path: import path);
  in {
    overlays = mkOverlays {
      helix = final: prev: (
        inputs.helix.packages.${final.system}.helix
      );

      qemu-new = final: prev: prev.qemu.overrideAttrs (old: rec {
        version = "9.2.0";
        src = final.fetchurl {
          url = "https://download.qemu.org/qemu-${version}.tar.xz";
          hash = "sha256-+FnwvGXh9TPQQLvoySvP7O5a8skhpmh8ZS+0TQib2JQ=";
        };
        patches = lib.filter (x: ! lib.elem (baseNameOf x) [
          "fix-qemu-ga.patch"
          "xfk3xqxdz4ibi209b25d6ir9jp5nmybj-ac1bbe8ca46c550b3ad99c85744119a3ace7b4f4.diff"
          "b83md1mbr85n7mk3jyagimn91k3457md-99174ce39e86ec6aea7bb7ce326b16e3eed9e3da.diff"
        ]) old.patches;
      });

      mesa-demos = final: prev: prev.mesa-demos.overrideAttrs (old: rec {
        mesonFlags = [
          "-Dosmesa=disabled"
          "-Dwith-system-data-files=true"
        ];
      });

      slang-shader-compiler = final: prev:
        let
          # dependency for this library has been removed in master (i.e. next release)
          unordered_dense = final.stdenv.mkDerivation rec {
            version = "2.0.1";
            pname = "unordered_dense";
            src = final.fetchFromGitHub {
              owner = "martinus";
              repo = pname;
              rev = "v${version}";
              sha256 = "sha256-9zlWYAY4lOQsL9+MYukqavBi5k96FvglRgznLIwwRyw=";
            };
            nativeBuildInputs = with final; [
              cmake
            ];
          };

          imgui-old = final.imgui.overrideAttrs (old: {
            outputs = ["out"];
            src = final.fetchFromGitHub {
              owner = "ocornut";
              repo = "imgui";
              rev = "3c15dffc944419eb4bb17984548468270ca90486";
              sha256 = "sha256-GZ8OJqmQ9gQEgKkKbp5gMaFMrlj640yQpncvL6kj6yg=";
            };
            cmakeRules = let
              vcpkgSource = final.fetchFromGitHub {
                owner = "microsoft";
                repo = "vcpkg";
                rev = "7befb86005462db5ad8ccf26ab4a370226ae614f";
                hash = "sha256-QXdUCzhT88lTUDE5oAB0T8Lmo/ufXwhJ+yXKuECGxBQ=";
              };
            in "${vcpkgSource}/ports/imgui";
          });
        in
       final.stdenv.mkDerivation {
        pname = "slang";
        version = "unstable";

        src = inputs.slang;

        # src = final.fetchFromGitHub {
        #   owner = "shader-slang";
        #   repo = "slang";
        #   rev = "dbc28b4fe9b0a6e8215640c04a9f245c150150a8";
        #   sha256 = "sha256-beczsP5Fen0Icb3FYsONI0EjTF8zII89oxxVnwtSazI=";
        #   fetchSubmodules = true;
        # };

        cmakeFlags = [
          "-DCMAKE_BUILD_TYPE=Release"

          "-DSLANG_ENABLE_PREBUILT_BINARIES=OFF"
          "-DSLANG_ENABLE_SLANG_RHI=OFF"

          "-DSLANG_EMBED_STDLIB_SOURCE=ON"
          "-DSLANG_EMBED_STDLIB=ON"

          "-DSLANG_EMBED_CORE_MODULE=ON"
          "-DSLANG_EMBED_CORE_MODULE_SOURCE=ON"

          "-DSLANG_ENABLE_SLANG_GLSLANG=OFF"

          "-DSLANG_USE_SYSTEM_MINIZ=ON"
          "-DSLANG_USE_SYSTEM_LZ4=ON"
          "-DSLANG_USE_SYSTEM_VULKAN_HEADERS=ON"
          "-DSLANG_USE_SYSTEM_UNORDERED_DENSE=ON"

          "-DSLANG_SLANG_LLVM_FLAVOR=DISABLE"

          "-DSLANG_ENABLE_EXAMPLES=OFF"

          "-DSLANG_USE_SYSTEM_SPIRV_HEADERS=ON"

          # "-DSLANG_ENABLE_SLANG_GLSLANG=OFF"
          # "-DSLANG_USE_SYSTEM_SPIRV_HEADERS=OFF"
          "-DSLANG_SPIRV_HEADERS_INCLUDE_DIR=${final.spirv-headers}/include"
        ];

        nativeBuildInputs = with final; [
          cmake ninja
          vulkan-headers
          spirv-headers
          pkg-config
          (miniz.overrideAttrs (old: {
            preFixup = ''
              ls -la
              echo '-----'
              cp $out/include/miniz/* $out/include/
              ls -la $out/include
              # exit -1
            '';
          }))
          python3

          glm

          (tinyobjloader.overrideAttrs (old: {
            src = fetchFromGitHub {
              owner = "tinyobjloader";
              repo = "tinyobjloader";
              rev = "d541711a794343de4ef5ea76f037c9fb9c127a55";
              sha256 = "sha256-QjJ2nh6B+engUKViVaZ3MZf5O2v0ZYFkfXuh/j6nCBk=";
            };
          }))
          # pkgsStatic.lz4
        ];

        buildInputs = with final; [
          lz4
          unordered_dense
          imgui-old

          # pkgsStatic.lz4
          # miniz
          # lz4
          spirv-tools
          pkg-config
          cmake
          xorg.libX11
        ];

        postPatch = ''
          rmdir external/imgui/
          ln -fTs ${imgui-old.src} external/imgui

          # substituteInPlace ./source/core/slang-deflate-compression-system.cpp \
          #   --replace-fail '<miniz.h>' '<miniz/miniz.h>'

          # substituteInPlace ./source/core/slang-lz4-compression-system.cpp \
          #   --replace-fail '<lz4.h>' '<lz4/lz4.h>'

          # substituteInPlace ./external/CMakeLists.txt \
          #   --replace-fail 'if(NOT ''${SLANG_USE_SYSTEM_SPIRV_HEADERS})' 'if(FALSE)'
          substituteInPlace ./source/core/CMakeLists.txt --replace-fail 'lz4_static' 'lz4'
          substituteInPlace ./source/slang-rt/CMakeLists.txt --replace-fail 'lz4_static' 'lz4'
          substituteInPlace ./source/slang-wasm/CMakeLists.txt --replace-fail 'lz4_static' 'lz4'

          substituteInPlace ./tools/CMakeLists.txt --replace-fail 'Vulkan-Headers' ""
          substituteInPlace ./source/slang/CMakeLists.txt --replace-fail 'SPIRV-Headers' ""
          substituteInPlace ./source/compiler-core/CMakeLists.txt --replace-fail 'INCLUDE_FROM_PUBLIC SPIRV-Headers' ""
          substituteInPlace ./source/slang-core-module/CMakeLists.txt --replace-fail 'SPIRV-Headers' ""

          substituteInPlace source/core/slang-dictionary.h --replace-fail '../../external/unordered_dense/include/ankerl/unordered_dense.h' 'ankerl/unordered_dense.h'
          substituteInPlace source/core/slang-hash.h --replace-fail '../../external/unordered_dense/include/ankerl/unordered_dense.h' 'ankerl/unordered_dense.h'

          substituteInPlace source/core/slang-deflate-compression-system.cpp --replace-fail 'miniz.h' 'miniz/miniz.h'
          substituteInPlace source/core/slang-zip-file-system.cpp --replace-fail 'miniz.h' 'miniz/miniz.h'

          substituteInPlace tools/platform/gui.h --replace-fail 'external/imgui/imgui.h' 'imgui.h'

          # substituteInPlace tools/platform/gui.cpp --replace-fail '#include <imgui.cpp>' ""
          # substituteInPlace tools/platform/gui.cpp --replace-fail '#include <imgui_draw.cpp>' ""
          # substituteInPlace tools/platform/gui.cpp --replace-fail '#include <imgui_widgets.cpp>' ""

          substituteInPlace tools/platform/vector-math.h --replace-fail '../../external/glm/' ""
          substituteInPlace tools/platform/model.cpp --replace-fail '../../external/glm/' ""

          substituteInPlace tools/platform/model.cpp --replace-fail '../../external/tinyobjloader/tiny_obj_loader.h' "tiny_obj_loader.h"

          # substituteInPlace tools/CMakeLists.txt --replace-fail 'EXPORT_MACRO_PREFIX SLANG_PLATFORM' "EXPORT_MACRO_PREFIX SLANG_PLATFORM LINK_WITH_PUBLIC imgui"

          # substituteInPlace ./cmake/SlangTarget.cmake --replace-fail 'SPIRV-Headers' ' '
          # substituteInPlace ./tools/CMakeLists.txt --replace-fail 'SPIRV-Headers' ' '
          # exit 1
        '';
          # cp -r --no-preserve=mode ${glslang} third_party/glslang
          # cp -r --no-preserve=mode ${spirv-tools} third_party/spirv-tools
          # patchShebangs --build utils/
      };

      mypaint = final: prev: (
        prev.mypaint.overrideAttrs (old: {
          doInstallCheck = false;
          checkPhase = null;
        })
      );

      openobserve = final: prev: (
        prev.openobserve.override {
          rustPlatform = final.rustPlatform // {
            buildRustPackage = args: final.rustPlatform.buildRustPackage (args // rec {
              src = inputs.openobserve;
              cargoLock.lockFile = "${src}/Cargo.lock";
              cargoLock.outputHashes = {
                "chromiumoxide-0.5.7" = "sha256-GHrm5u8FtXRUjSRGMU4PNU6AJZ5W2KcgfZY1c/CBVYA=";
                "enrichment-0.1.0" = "sha256-FDPSCBkx+DPeWwTBz9+ORcbbiSBC2a8tJaay9Pxwz4w=";
              };
              doCheck = false;
            });
          };
          buildNpmPackage = args: final.buildNpmPackage (args // {
            src = inputs.openobserve;
            sourceRoot = "source/web";
            npmDeps = final.importNpmLock {
              npmRoot = "${inputs.openobserve}/web";
            };
            npmConfigHook = final.importNpmLock.npmConfigHook;
          });
        }
      );

      caddyWith = final: prev: with final; (
        { plugins, vendorHash, caddyRev ? caddy.src.rev }: (
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
                    ${lib.concatMapStringsSep " " ({ src, rev }: "--with ${src}@${rev}") plugins}
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
          }
        )
      );

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

        nativeBuildInputs = old.nativeBuildInputs ++ [ final.addDriverRunpath ];
        postFixup = old.postFixup + ''
          addDriverRunpath $out/bin/nvtop
        '';
      });

      sway-unwrapped = final: prev:
        with inputs.nixpkgs-wayland.packages.${final.system};
          (sway-unwrapped.override {
            wlroots = wlroots.overrideAttrs (old: {
              src = final.fetchFromGitLab {
                domain = "gitlab.freedesktop.org";
                owner = "emersion";
                repo = "wlroots";
                rev = "544eebe0ac2eafb08abf18e535357fa53eaf4df2";
                hash = "sha256-xsk/9eojA0UvOdkrtBsjcXi0mlp6jENLRsM7MJln/Zw=";
                # https://gitlab.freedesktop.org/emersion/wlroots/-/tree/ext-screencopy-v1-ng
              };
              # patches = old.patches ++ [
              #   (final.fetchpatch {
              #     domain = "gitlab.freedesktop.org";
              #     owner = "wlroots";
              #     repo = "wlroots";
              #     rev = "eb554f07e16b59248b64c046bad08957f02bb805";
              #     # url = "https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/4545.patch";
              #     # hash = "sha256-JpLftNx6bwUTa7qePBr4uy/rrQ8EPeif/sqXfRA/I34=";
              #   })
              # ];
            });
          }).overrideAttrs (old: {
            patches = old.patches ++ [
              (final.fetchpatch {
                url = "https://github.com/swaywm/sway/commit/e53b44f18cddcf96f426a7a386a99dc0ff2b72e6.patch";
                hash = "sha256-OdM8Rk/VTxmo9q7i0sNChaiGMHojSZmUCgdqCAaBMLE=";
              })
            ];
          });
    };

    nixosModules = mkNixosModules {
      unfree = ./modules/unfree.nix;
      terraria = ./modules/terraria.nix;
      stalwart-mail = ./modules/stalwart-mail.nix;
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
