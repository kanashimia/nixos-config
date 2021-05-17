{ options, modulesPath, pkgs, inputs, config, ... }:

{
  imports = [
    ./networking.nix
    ./swap.nix
    ./nginx.nix
    ./ssh.nix
    ./boot.nix
    ./swap.nix
    #"${modulesPath}/profiles/headless.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    #"${modulesPath}/profiles/hardened.nix"
    #"${modulesPath}/installer/cd-dvd/iso-image.nix"
    #"${modulesPath}/profiles/all-hardware.nix"
    # "${modulesPath}/profiles/minimal.nix"
  ];

}
