{
  nrs = "sudo nixos-rebuild switch -L";
  nrsr = "sudo nixos-rebuild switch -L --rollback";
  nrb = "sudo nixos-rebuild boot -L";
  nrbr = "sudo nixos-rebuild boot -L && reboot";

  nfu = "nix flake update";

  rdm = "systemctl restart display-manager";

  ga = "git add";
  gc = "git commit";
  gp = "git push";
}
