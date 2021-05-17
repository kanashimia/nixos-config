{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    git
    unar
    xsel
    
    fd
    ripgrep
    tree
    dua

    nix-tree
    hydra-check

    linuxPackages.perf

    pciutils
    usbutils
    inxi
    neofetch
    htop
    acpi

    gdb
    ltrace
  ];
}
