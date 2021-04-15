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

    nix-du
    nix-tree
    nix-index
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
