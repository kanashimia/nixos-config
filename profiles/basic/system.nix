{ lib, config, ... }: {
  boot.loader.efi.canTouchEfiVariables = true;

  # Do not show boot loader menu unless explicitly desired.
  # It is still accessible by holding random keys during early boot.
  boot.loader.timeout = lib.mkIf config.boot.loader.systemd-boot.enable 0;

  boot.initrd.systemd.enable = true;

  services.userborn.enable = true;
  # systemd.sysusers.enable = true;

  # Do not print sometimes helpful, but not always, info during boot,
  # so it is harder to debug system when something goes wrong.
  boot.kernelParams = [ "quiet" "systemd.show_status=auto" ];
  boot.initrd.verbose = false;

  services.dbus.implementation = "broker";

  systemd.coredump.settings.Coredump = {
    Storage = "none";
    ProcessSizeMax = 0;
  };

  security.sudo.enable = false;

  security.account-utils.enable = true;

  assertions = [ {
    assertion = !lib.any (v: v.enable) (lib.attrValues config.security.wrappers);
    message = "some idiot added another security wrapper that you must disable: "
      + (lib.concatStringsSep ", " (lib.attrNames (lib.filterAttrs (_: v: v.enable) config.security.wrappers)));
  } ];

  security.wrappers = {
    mount.enable = false;
    umount.enable = false;
    su.enable = false;
    sg.enable = false;
    newgrp.enable = false;
    fu.enable = false;
    fusermount.enable = false;
    fusermount3.enable = false;
  };

  # security.wrappers = let
  #   mkSetgidShadow = source: {
  #     setgid = true;
  #     owner = "root";
  #     group = "shadow";
  #     inherit source;
  #   };
  # in lib.mkForce {
  #   # unix_chkpwd = mkSetgidShadow "${config.security.pam.package}/bin/unix_chkpwd";
  # };

  # security.enableWrappers = false;
  # systemd.tmpfiles.rules = [
  #   "d /run/wrappers/bin 0755 root root - -"
  #   "L+ /run/wrappers/bin/unix_chkpwd - - - - /run/current-system/sw/bin/unix_chkpwd"
  # ];
}
