{ nixosModules, pkgs, ... }:


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
in
{
  imports = with nixosModules; [
    profiles.basic
    window-managers.xmonad
    terminals.alacritty
    themes.colors
    profiles.users.kanashimia
    shells.zsh
  ];

  services.xserver.libinput.enable = true;
  # services.xserver.libinput.touchpad.disableWhileTyping = true;

  # Enable SysRq key for unexpected situations.
  boot.kernel.sysctl."kernel.sysrq" = 1;

  environment.systemPackages = with pkgs; [ alsaUtils pentbl ];
  nixpkgs.config.allowUnfree = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"   ; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio" ; type = "-"   ; value = "99"       ; }
    { domain = "@audio"; item = "nofile" ; type = "soft"; value = "99999"    ; }
    { domain = "@audio"; item = "nofile" ; type = "hard"; value = "99999"    ; }
  ];

  systemd.services.rtkit-daemon.serviceConfig.ExecStart = [
    "" "${pkgs.rtkit}/libexec/rtkit-daemon --our-realtime-priority=95 --max-realtime-priority=90"
  ];

  services.xserver.digimend.enable = true;

  # hardware.opentabletdriver.enable = true;
  
  # services.udev.extraHwdb = ''
  #   evdev:input:b0003v28BDp0904e0100-e0,1,2,4*
  #     KEYBOARD_KEY_90001=100
  #     KEYBOARD_KEY_90002=101
  #     KEYBOARD_KEY_90003=102
  #     KEYBOARD_KEY_90004=103
  #     KEYBOARD_KEY_90005=104
  #     KEYBOARD_KEY_90006=105
  #     KEYBOARD_KEY_90007=undo
  #     KEYBOARD_KEY_90008=redo
  # '';
  
  # services.udev.extraHwdb = ''
  #   id-input:modalias:input:b0003v28BDp0904e0100-e0,1,2,4*
  #     ID_INPUT_TABLET=1
  #     ID_INPUT_TABLET_PAD=1
  # '';
    
  services.xserver.inputClassSections = [''
    Identifier "Tablet"
    MatchUSBID "28bd:0904"
    MatchDevicePath "/dev/input/event*"
    Driver "wacom"
  ''];
}

