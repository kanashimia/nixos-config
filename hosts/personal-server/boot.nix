{ modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  users.users.root.initialHashedPassword = "";

  zramSwap.enable = true;

  profiles.minimal.enable = true;

  fileSystems."/".label = "nixos";

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  services.openssh.enable = true;
}
