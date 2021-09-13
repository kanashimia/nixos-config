{ pkgs, lib, ... }:

{
  services.xserver.libinput.enable = true;

  # services.xserver.wacom.enable = true;
  services.xserver.digimend.enable = true;

  users.users.kanashimia.extraGroups = [ "plugdev" ];
  users.groups.plugdev = {};
  # services.udev.packages = [ pkgs.xp-pen-userland ];
  environment.etc."X11/xorg.conf.d/60-xp-pen.conf".source =
    "${pkgs.xp-pen-userland}/share/X11/xorg.conf.d/60-xp-pen.conf";

  systemd.user.services.xp-pen-userland = {
    description = "Userland driver for XP-Pen tablets";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${pkgs.xp-pen-userland}/bin/xp_pen_userland";
  };
  
  # services.udev.packages = [ pkgs.pentablet-driver ];
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="plugdev", OPTIONS+="static_node=uinput"
    SUBSYSTEM=="usb", ATTR{idVendor}=="28bd", GROUP="users", TAG+="uaccess"
  '';

  # KERNEL=="uinput", GROUP="plugdev", MODE="0660"
  #, OPTIONS+="static_node=uinput"

  # KERNEL=="uinput",MODE:="0666",OPTIONS+="static_node=uinput"
  # SUBSYSTEMS=="usb",ATTRS{idVendor}=="28bd",MODE:="0666"

  # services.xserver.inputClassSections = [''
  #   Identifier "XP-Pen Deco Pro M"
  #   MatchUSBID "28bd:0904"
  #   MatchDevicePath "/dev/input/event*"
  #   Driver "wacom"
  # ''];

  # services.xserver.inputClassSections = [''
  #   Identifier "XP-Pen Deco Pro MD Tablet"
  #   MatchUSBID "28bd:0904"
  #   MatchDevicePath "/dev/input/event*"
  #   MatchIsTablet "on"
  #   Driver "wacom"
  #   Option "PressCurve" "64,7,81,46"
  #   Option "Threshold" "27"
  # '' ''
  #   Identifier "XP-Pen Deco Pro MD Frame"
  #   MatchUSBID "28bd:0904"
  #   MatchIsKeyboard "on"
  #   MatchDevicePath "/dev/input/event*"
  #   Driver "libinput"
  # '' ''
  #   Identifier "XP-Pen Deco Pro MD Pointer"
  #   MatchUSBID "28bd:0904"
  #   MatchIsPointer "on"
  #   MatchDevicePath "/dev/input/event*"
  #   Driver "libinput"
  # ''];

  environment.systemPackages = with pkgs; [ xp-pen-userland pentablet-driver krita gimp ];

  nixpkgs.config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) [
    "pentablet-driver"
  ];
}
    
