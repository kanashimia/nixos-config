{ nixosModules, ... }:

{
  imports = with nixosModules; [
    profiles.qemu-guest
    profiles.minimal
  ];

  fileSystems."/".label = "nixos";

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };
}
