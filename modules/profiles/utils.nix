{ pkgs, ... }: {
  # Various useful utils.
  environment.systemPackages = with pkgs; [
    ripgrep fd sd tree dua nix-tree
    pciutils usbutils htop acpi hydra-check
    strace ltrace hyperfine
    atool 
  ];
}
