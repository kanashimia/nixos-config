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

    linuxPackages.perf

    pciutils
    glxinfo
    inxi
    neofetch
    htop
  ];
}
