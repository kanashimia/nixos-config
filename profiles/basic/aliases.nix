{
  environment.shellAliases = let
    rebuild = cmd: "systemd-inhibit nixos-rebuild ${cmd} --flake flake:nixos -L --no-reexec";
  in {
    nrs = rebuild "switch";
    nrb = rebuild "boot";
    nrbr = rebuild "boot" + "&& reboot";
    nrt = rebuild "test";

    ns = "nix shell";
    nr = "nix run";

    nfu = "nix flake update";
    nfl = "nix flake lock";

    # su = "machinectl shell";
    # su = "systemd-run --shell -E SHELL -q";
    su = "run0 --background= -- ";
    sudo = "sudo ";
    # sudo = "run0 --background= --setenv=SHELL --setenv=LOCALE_ARCHIVE --setenv=TZDIR --setenv=PATH --setenv=EDITOR -- ";
    # sudo = "systemd-run --pty --same-dir --wait --collect --service-type=exec "
    #   + "--quiet -E SHELL -E LOCALE_ARCHIVE -E TZDIR -E PATH -E EDITOR -- ";

    diff = "diff --color=auto";
    grep = "grep --color=auto";

    rm = "rm -vI";
    rmr = "rm -Ir";

    l = "ls -lAh --group-directories-first";
    ll = "ls -la --group-directories-first";
    ls = "ls --color=tty";

    cdr = ''cd "$(git rev-parse --show-toplevel)"'';

    adb = "HOME=~/.local/share/android adb";

    mkx = "chmod +x";
    cdtmp = "cd $(mktemp -d /tmp/test-some-trash.XXXXXXXX)";
  };

  environment.interactiveShellInit = /*bash*/''
    function nd() {
      local p
      nix flake archive --json | \
        jq -r '.inputs | to_entries[] | .value.path' | \
        while read -r p; do \
          ln -fsT "$p" /nix/var/nix/profiles/per-user/"$USER"/"''${p//\//_}"; \
        done
      nix develop "$@" \
        --profile /nix/var/nix/profiles/per-user/"$USER"/develop \
        -c env SHELL="$SHELL" "$SHELL"
    }

    function ndwith() {
      nix develop --impure --expr \
        "with (builtins.getFlake \"n\").legacyPackages.$""{builtins.currentSystem};
        mkShell { packages = [ $* ]; }" \
        -c "$SHELL"
    }

    function y() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      yazi "$@" --cwd-file="$tmp"
      IFS= read -r -d "" cwd < "$tmp"
      [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
      rm -f -- "$tmp"
    }
  '';
}
