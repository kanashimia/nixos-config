{ pkgs, ... }: {
  services.xserver = {
    libinput.enable = true;
    digimend.enable = true;
  };

  environment.systemPackages = with pkgs; [
    krita mypaint sxiv
  ];

  services.xserver.inputClassSections = [''
    Identifier "XP-Pen Deco Pro M"
    MatchUSBID "28bd:0904"
    MatchDevicePath "/dev/input/event*"
    Driver "wacom"
  ''];
}
   
