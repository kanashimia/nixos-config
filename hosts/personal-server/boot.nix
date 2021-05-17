{ pkgs, ... }:

{
  users.users.root.initialHashedPassword = "";
  services.getty.autologinUser = "root";
  security.sudo.enable = false;

  documentation.enable = false;
  documentation.nixos.enable = false;

  fileSystems."/" = {
    device = "/dev/vda1";
    # label = "nixos";
    fsType = "ext4";
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };
}
