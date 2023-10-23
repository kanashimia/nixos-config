{ pkgs, lib, ... }: {
  # Configuration of the xdg user dirs to create,.
  # As you may see i've added PROJECTS dir,
  # and made so all dirs are in lowercase.
  environment.etc."xdg/user-dirs.defaults".text = ''
    DOCUMENTS=documents
    DOWNLOAD=downloads
    MUSIC=music
    PICTURES=pictures
    PROJECTS=projects
    TEMPLATES=templates
  '';

  # services.xserver.displayManager.sessionCommands = ''
  #   ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update &
  # '';

  environment.variables = let
    data = "\${XDG_DATA_HOME:-$HOME/.local/share}";
    cache = "\${XDG_CACHE_HOME:-$HOME/.cache}";
    config = "\${XDG_CONFIG_HOME:-$HOME/.config}";
    state = "\${XDG_STATE_HOME:-$HOME/.local/state}";
  in {
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";

    IPYTHONDIR = "${config}/ipython";

    JUPYTER_CONFIG_DIR = "${config}/jupyter";

    ANDROID_HOME = "${data}/android";

    TEXMFHOME = "${data}/texmf";
    TEXMFVAR = "${cache}/texmf";
    TEXMFCONFIG = "${config}/texmf";

    CARGO_HOME = "${data}/cargo";

    CUDA_CACHE_PATH = "${cache}/nv";

    NPM_CONFIG_USERCONFIG = "${config}/npm/npmrc";
    NPM_CONFIG_CACHE = "${cache}/npm";
    NPM_CONFIG_PREFIX = "${data}/npm";
  };
}
