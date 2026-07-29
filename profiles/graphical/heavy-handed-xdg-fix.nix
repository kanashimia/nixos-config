{ pkgs, lib, ... }: let
  wrapBinScript = pkg: bin: script: pkgs.symlinkJoin {
    inherit (pkg) pname version meta;
    paths = [
      (pkgs.writeShellScriptBin bin script)
      pkg
    ];
  };
  coolXdgFix = pkg: bin: dirName:
    wrapBinScript pkg bin /*bash*/''
      DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}"
      CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}"
      CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}"

      REAL_HOME="$HOME"
      HOME="$DATA_DIR/${dirName}/fakehome"

      function link() {
        mkdir -p "$1" "''${2%/*}"
        ln -sTf "$1" "$2"
      }

      link "$CACHE_DIR" ~/.cache
      link "$CONFIG_DIR" ~/.config
      link "$DATA_DIR" ~/.local/share

      USER_DIRS=~/.config/user-dirs.dirs
      if [ -e "$USER_DIRS" ]; then
        source "$USER_DIRS"
        link "''${XDG_DOWNLOAD_DIR/$HOME/$REAL_HOME}" "$XDG_DOWNLOAD_DIR"
        link "''${XDG_DOCUMENTS_DIR/$HOME/$REAL_HOME}" "$XDG_DOCUMENTS_DIR"
        link "''${XDG_PICTURES_DIR/$HOME/$REAL_HOME}" "$XDG_PICTURES_DIR"
      fi

      exec ${pkg}/bin/${bin} "$@"
    '';
  coolXdgFix' = pkg:
    let exe = pkg.meta.mainProgram;
    in coolXdgFix pkg exe exe;
in {
  programs.steam.package = pkgs.steam-xdg;

  nixpkgs.overlays = [ (final: prev: {
    steam-xdg = final.steam.override {
      steam-unwrapped = coolXdgFix final.steam-unwrapped "steam" "Steam";
    };
    # chromium-xdg = coolXdgFix' final.chromium;
    # firefox-xdg = coolXdgFix' final.firefox;
    # librewolf-xdg = coolXdgFix' final.librewolf;
    # thunderbird-xdg = coolXdgFix' final.thunderbird;
  }) ];
}
