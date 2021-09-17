{ pkgs, lib, ... }:

{
  services.xserver = {
    libinput.enable = true;
    digimend.enable = true;
  };

  users.users.kanashimia.extraGroups = [ "plugdev" ];
  users.groups.plugdev = {};

  services.udev.packages = [ pkgs.xp-pen-userland ];

  environment.etc."X11/xorg.conf.d/60-xp-pen.conf".source =
    "${pkgs.xp-pen-userland}/share/X11/xorg.conf.d/60-xp-pen.conf";

  systemd.user.services.xp-pen-userland = {
    description = "Userland driver for XP-Pen tablets";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${pkgs.xp-pen-userland}/bin/xp_pen_userland";
  };

  environment.systemPackages = with pkgs; [
    xp-pen-userland
    pentablet-driver
    krita
    mypaint
    sxiv
    evsieve
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) [
    "pentablet-driver"
  ];
}
    
