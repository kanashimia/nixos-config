{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    kakoune
    git
    xsel
    unstable.manix
    linuxPackages.perf
    fortune
    
    fd
    ripgrep
    tree

    pciutils
    glxinfo
    inxi
    xorg.xev
    neofetch
    htop
  ];

  nixpkgs.config.allowUnfree = true;
}
