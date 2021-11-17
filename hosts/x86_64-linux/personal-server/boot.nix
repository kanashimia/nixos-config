{ nixosModules, ... }: {
  imports = with nixosModules; [
    profiles.qemu-guest
    profiles.minimal
  ];

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
}
