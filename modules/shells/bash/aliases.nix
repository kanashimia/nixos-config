{
  nr-s = "sudo nixos-rebuild switch -L";
  nr-sr = "sudo nixos-rebuild switch -L --rollback";
  nr-b = "sudo nixos-rebuild boot -L";
  nr-br = "sudo nixos-rebuild boot -L && reboot";

  n-fu-rlf = "nix flake update --recreate-lock-file";

  sc-rdm = "systemctl restart display-manager";
  sc-s = "systemctl status";

  sa = "systemd-analyze";
  sa-p = "systemd-analyze plot";
  sa-b = "systemd-analyze blame";
  sa-cc = "systemd-analyze critical-chain";

  g-a = "git add";
  g-c = "git commit";
  g-p = "git push";
}
