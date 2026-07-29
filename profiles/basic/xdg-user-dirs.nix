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

  environment.sessionVariables = rec {
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";

    IPYTHONDIR = "${XDG_CONFIG_HOME}/ipython";

    JUPYTER_CONFIG_DIR = "${XDG_CONFIG_HOME}/jupyter";

    ANDROID_USER_HOME = "${XDG_DATA_HOME}/android";

    TEXMFHOME = "${XDG_STATE_HOME}/texmf";
    TEXMFVAR = "${XDG_CACHE_HOME}/texmf";
    TEXMFCONFIG = "${XDG_CONFIG_HOME}/texmf";

    CARGO_HOME = "${XDG_STATE_HOME}/cargo";
    CARGO_TARGET_DIR = "${XDG_STATE_HOME}/cargo";

    CUDA_CACHE_PATH = "${XDG_CACHE_HOME}/nv";

    NPM_CONFIG_USERCONFIG = "${XDG_CONFIG_HOME}/npm/npmrc";
    NPM_CONFIG_CACHE = "${XDG_CACHE_HOME}/npm";
    NPM_CONFIG_PREFIX = "${XDG_STATE_HOME}/npm";

    GRADLE_USER_HOME = "${XDG_DATA_HOME}/gradle";

    GOPATH = "${XDG_STATE_HOME}/go";

    BUNDLE_USER_CONFIG = "${XDG_CONFIG_HOME}/bundle";
    BUNDLE_USER_CACHE = "${XDG_CACHE_HOME}/bundle";
    BUNDLE_USER_PLUGIN = "${XDG_DATA_HOME}/bundle";

    KERAS_HOME = "${XDG_STATE_HOME}/keras";

    JULIA_DEPOT_PATH = "${XDG_DATA_HOME}/julia";

    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";

    SQLITE_HISTORY = "${XDG_CACHE_HOME}/sqlite_history";

    NODE_REPL_HISTORY = "${XDG_DATA_HOME}/node_repl_history";

    W3M_DIR = "${XDG_DATA_HOME}/w3m";

    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java";

    GNUPGHOME = "${XDG_DATA_HOME}/gnupg";
  };
}
