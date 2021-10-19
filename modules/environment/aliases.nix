{
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake nixos -L";
    ns = "nix shell";
    nr = "nix run";
    nd = "nix develop";
    s = "systemctl";
    j = "journalctl --no-hostname -eb -o short-monotonic";
    jw = "j -p notice";
    jf = "j -f";
    jk = "j -k";
    d = "dmesg";
  };
}
