{ pkgs, config, lib, ... }:

{
  systemd.package = pkgs.systemd.override { withOomd = true; };
  systemd.additionalUpstreamSystemUnits = [ "systemd-oomd.service" ];
  systemd.services.systemd-oomd = {
    wantedBy = lib.mkIf (config.swapDevices != []) [ "multi-user.target" ];
    after = [ "swap.target" ];
    aliases = [ "dbus-org.freedesktop.oom1.service" ];
  };
  
  users.groups.systemd-oom.gid = 666;
  users.users.systemd-oom.uid = 666;
  users.users.systemd-oom.group = "systemd-oom";

  systemd.slices."-".sliceConfig.ManagedOOMSwap = "kill";
}
