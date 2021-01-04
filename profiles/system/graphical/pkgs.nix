{ inputs, conf-utils, pkgs, ...}:

{
  # Allow unfree pkgs.
  nixpkgs.config.allowUnfree = true;

  # Import overlays, add overlay for installing pkgs from unstable.
  nixpkgs.overlays = [ (self: super: {
    unstable = inputs.unstable.legacyPackages.${super.system};
  }) ];

  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  # Key input diagnostic.
  environment.systemPackages = with pkgs; [
      xorg.xev
      gparted
  ];
}
