{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    thunderbird
  ];

  services.dbus.packages = with pkgs; [ dunst ];
  systemd.packages = with pkgs; [ dunst ];
  #systemd.user.services.bubblemaild = {
  #  description = "";
  #  serviceConfig = {
  #    ExecStart = "${pkgs.bubblemail}/bin/bubblemaild";
  #    Restart = "on-failure";
  #  };
  #  wantedBy = [ "graphical-session.target" ];
  #};
  services.gnome3.gnome-keyring.enable = true;
}
