{ inputs, conf-utils, pkgs, ...}:

{
  # Allow unfree pkgs
  nixpkgs.config.allowUnfree = true;

  # Import overlays, add overlay for installing pkgs from unstable.
  nixpkgs.overlays = map import (conf-utils.listFiles ../../../overlays) ++ [
    (self: super: {
      unstable = inputs.unstable.legacyPackages.${super.system};
    })
  ];

  services.dbus.packages = with pkgs; [ gnome3.dconf ];
}
