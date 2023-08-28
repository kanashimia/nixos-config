{
  environment.shellAliases = let
    rebuild = cmd: "systemd-inhibit nixos-rebuild ${cmd} --flake nixos -L";
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
    su = "systemd-run --shell -E SHELL -q";
    sudo = "systemd-run --pty --same-dir --wait --collect --service-type=exec "
      + "--quiet -E SHELL -E LOCALE_ARCHIVE -E TZDIR -E PATH -- ";

    ip = "ip --color=auto";
    diff = "diff --color=auto";
    grep = "grep --color=auto";

    rm = "rm -vI";
    rmr = "rm -vIr";

    l = "ls -lAh --group-directories-first";
    ll = "ls -la --group-directories-first";
    ls = "ls --color=tty";
  };

  environment.interactiveShellInit = ''
    function nd() {
      nix develop "$@" \
        --profile /nix/var/nix/profiles/per-user/"$USER"/develop \
        -c "$SHELL"
    }

    function ndwith() {
      nix develop --impure --expr \
        "with (builtins.getFlake "n").legacyPackages.$""{builtins.currentSystem};
        mkShell { packages = [ $* ]; }" \
        -c "$SHELL"
    }
  '';
}
