{ pkgs, ... }: {
  services.xserver = {
    libinput.enable = true;
    digimend.enable = true;
  };

  environment.systemPackages = with pkgs; [
    krita mypaint
  ];
  services.udev.extraHwdb = ''
    evdev:input:b0003v28BDp0904e0100-e0,1,2,4*r6*
      KEYBOARD_KEY_90001=btn_0
      KEYBOARD_KEY_90002=btn_1
      KEYBOARD_KEY_90003=btn_2
      KEYBOARD_KEY_90004=btn_3
      KEYBOARD_KEY_90005=btn_4
      KEYBOARD_KEY_90006=btn_5
      KEYBOARD_KEY_90007=btn_6
      KEYBOARD_KEY_90008=btn_7
  '';
}
   
