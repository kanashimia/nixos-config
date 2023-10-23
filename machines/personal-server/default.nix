{ modulesPath, ... }: {
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    ./vpn.nix
    ./ssh.nix
    ./server.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "21.05";
}
