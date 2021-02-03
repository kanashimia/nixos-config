{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    kakoune
    git
    unar
    xsel
    
    fd
    ripgrep
    tree

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
