{ pkgs, ... }:

{
  services.xserver = {
    libinput.enable = true;
    digimend.enable = true;
  };

  environment.systemPackages = with pkgs; [
    krita mypaint sxiv
  ];
}
   
