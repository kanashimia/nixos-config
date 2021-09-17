{ pkgs, ... }:

{
  # Various useful utils.
  environment.systemPackages = with pkgs; [
    # Searching.
    ripgrep fd tree dua nix-tree

    # Info.
    pciutils usbutils htop acpi

    # Debugging.
    ltrace gdb hyperfine

    # Misc.
    atool xsel hydra-check
  ];
}
