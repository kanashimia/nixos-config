{ pkgs, ... }:

let
  pentbl = pkgs.pentablet-driver.overrideAttrs (old: rec {
    version = "3.2.0.210824-1";
    src = pkgs.fetchurl {
      url = "https://download01.xp-pen.com/file/2021/08/XP-PEN-pentablet-${version}.x86_64.tar.gz";
      sha256 = "sha256-JPqeBkMsODt/ddiX/BF4b36FG+F5BhULMK4oVr6jG8g=";
    };
    installPhase = ''
      mkdir -p $out/bin
      cp -R App/usr/lib/pentablet/* $out/bin
      rm -rf $out/bin/lib
    '';
    buildInputs = old.buildInputs ++ [ pkgs.qt5Full ];
  });
in {
  services.xserver.libinput.enable = true;

  services.xserver.wacom.enable = true;

  users.users.kanashimia.extraGroups = [ "plugdev" ];
  users.groups.plugdev = {};
  services.udev.packages = [ pkgs.xp-pen-userland ];
  environment.etc."X11/xorg.conf.d/60-xp-pen.conf".source =
    "${pkgs.xp-pen-userland}/share/X11/xorg.conf.d/60-xp-pen.conf";

  boot.kernelModules = [ "uinput" ];
  systemd.user.services.xp-pen-userland = {
    description = "Userland driver for XP-Pen tablets";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${pkgs.xp-pen-userland}/bin/xp_pen_userland";
  };

  services.xserver.inputClassSections = [''
    Identifier "XP-Pen Deco Pro MD Tablet"
    MatchUSBID "28bd:0904"
    MatchDevicePath "/dev/input/event*"
    MatchIsTablet "on"
    Driver "wacom"
    Option "PressCurve" "64,7,81,46"
    Option "Threshold" "27"
  '' ''
    Identifier "XP-Pen Deco Pro MD Frame"
    MatchUSBID "28bd:0904"
    MatchIsKeyboard "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
  '' ''
    Identifier "XP-Pen Deco Pro MD Pointer"
    MatchUSBID "28bd:0904"
    MatchIsPointer "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
  ''];

  environment.systemPackages = with pkgs; [ krita gimp ];
}
    
