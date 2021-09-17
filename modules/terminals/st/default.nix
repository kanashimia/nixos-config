{ pkgs, inputs, config,	 ... }:

let
  st-config = pkgs.substituteAll (
    config.themes.colors // {
      src = ./config.h;
      font = "DejaVu Sans Mono:size=11";
    }
  );

  st-overlay = final: prev: {
    st = prev.st.overrideAttrs (old: rec {
      patches = map final.fetchpatch [
        { url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff";
          sha256 = "bGRSALFWVuk4yoYON8AIxn4NmDQthlJQVAsLp9fcVG0=";
        }
        { url = "https://st.suckless.org/patches/scrollback/st-scrollback-mouse-20191024-a2c479c.diff";
          sha256 = "Z61Lx3jIeYy77/CbF17mnv/o41oWXusso6VGYrYG4mE=";
        }
      ];
      postPatch = "cp ${st-config} config.h";
    });
  };
in {
  nixpkgs.overlays = [ st-overlay ];
  environment.systemPackages = [ pkgs.st ];
}
