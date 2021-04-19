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
    inxi
    neofetch
    htop
    acpi

    gdb
    ltrace
  ];
}
