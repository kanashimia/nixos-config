{ inputs, conf-utils, pkgs, ...}:

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

  # Allow unfree pkgs
  nixpkgs.config.allowUnfree = true;

  # Import overlays, add overlay for installing pkgs from unstable.
  nixpkgs.overlays = map import (conf-utils.listFiles ../overlays) ++ [
    (self: super: {
      unstable = inputs.unstable.legacyPackages.${super.system};
    })
  ];

}
