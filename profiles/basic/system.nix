{ lib, config, ... }: {
  boot.loader.efi.canTouchEfiVariables = true;

  # Do not show boot loader menu unless explicitly desired.
  # It is still accessible by holding random keys during early boot.
  boot.loader.timeout = lib.mkIf config.boot.loader.systemd-boot.enable 0;

  boot.initrd.systemd.enable = true;

  system.switch.enable = false;
  system.switch.enableNg = true;

  # Do not print sometimes helpful, but not always, info during boot,
  # so it is harder to debug system when something goes wrong.
  boot.kernelParams = [ "quiet" ];

  services.dbus.implementation = "broker";

  systemd.coredump.extraConfig = ''
    Storage=none
    ProcessSizeMax=0
  '';

  security.sudo.enable = false;
}
