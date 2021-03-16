{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    git
    unar
    xsel
    
    fd
    ripgrep
    tree
    du-dust
    gdu

    nix-index
    hydra-check
    nix-du

    linuxPackages.perf

    pciutils
    glxinfo
    inxi
    neofetch
    htop
    acpi
    iasl
    iw

    valgrind
    gdb
  ];
}
