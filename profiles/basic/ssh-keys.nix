{ lib, ... }: {
  users.users.root.openssh.authorizedKeys.keys = lib.attrValues {
    ati-workstation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFKT4IvaipZW694RsavGtogmPj8NAEpai0SxDpenGdc6";
    hp-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICCY/7XSfCq7YTu7/z3Dzm1FzVaPbBrCvdOM2opDUm15";
    personal-server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/jCp7yrN/UtgzaqkHMlyC85j9k0Lp9GUjm15vFJ2zE";
    phone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIcn4F+RJbvCc26T2ZolAuWVmMgP+t7TchXMWWAqKy+";
  };
}
