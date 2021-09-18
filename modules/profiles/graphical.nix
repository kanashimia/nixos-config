{ nixosModules, pkgs, ... }:

{
  imports = with nixosModules; [
    profiles.basic
    window-managers.xmonad
    terminals.alacritty
    terminals.st
    themes.colors
    profiles.users.kanashimia
    profiles.drawing
    profiles.pipewire
    profiles.utils
    profiles.music
    shells.zsh
  ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.disableWhileTyping = true;

  # Enable SysRq key for unexpected situations.
  boot.kernel.sysctl."kernel.sysrq" = 1;


  #services.udev.extraRules = ''
  #  KERNEL=="uinput", GROUP="plugdev", MODE="0660"
  #  SUBSYSTEM=="usb", ATTR{idVendor}=="28bd", GROUP="users", TAG+="uaccess"
  #'';


  # services.xserver.digimend.enable = true;

  # hardware.opentabletdriver.enable = true;
  
  # services.udev.extraHwdb = ''
  #   id-input:modalias:input:b0003v28BDp0904e0100-e0,1,2,4*r6*
  #     ID_INPUT_TABLET=1
  #     ID_INPUT_TABLET_PAD=1
  #     ID_INPUT_KEY=0
  # '';
  #   evdev:input:b0003v28BDp0904e0100-e0,1,2,4*r6*
  #     KEYBOARD_KEY_90001=forward
  #     KEYBOARD_KEY_90002=insert
  #     KEYBOARD_KEY_90003=undo
  #     KEYBOARD_KEY_90004=redo
  #     KEYBOARD_KEY_90005=pageup
  #     KEYBOARD_KEY_90006=pagedown
  #     KEYBOARD_KEY_90007=leftctrl
  #     KEYBOARD_KEY_90008=leftshift
  #    
  #   # id-input:modalias:input:b0003v28BDp0904e0100*
  #   #   ID_INPUT_TABLET=1
  #   #   ID_INPUT_TABLET_PAD=1
  #   #   ID_INPUT_KEY=0
  # 
  #   # id-input:modalias:input:b0003v28BDp0904e0100-e0,1,2,4*r6*
  #   #   ID_INPUT_TABLET=1
  #   #   ID_INPUT_TABLET_PAD=1
  #   #   ID_INPUT_KEY=0

  #   # id-input:modalias:input:b0003v28BDp0904e0100-e0,1,2,4*r0*
  #   # id-input:modalias:input:b0003v28BDp0904e0100-e0,1,4*ram4*
  #   #   ID_INPUT=0
  #   #   ID_INPUT_KEY=0
  #   #   ID_INPUT_KEYBOARD=0
  #   #   ID_INPUT_MOUSE=0
   # services.xserver.inputClassSections = [''
   #   Identifier "XP-Pen Deco Pro M"
   #   MatchUSBID "28bd:0904"
   #   MatchDevicePath "/dev/input/event*"
   #   MatchIsTablet "yes"
   #   Driver "wacom"
   # ''];
}

