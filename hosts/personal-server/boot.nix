{ modulesPath, inputs, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  users.users.root.initialHashedPassword = "";

  profiles.minimal.enable = true;

  fileSystems."/".label = "nixos";
  swapDevices = [ { label = "swap"; } ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  services.openssh.enable = true;
}
