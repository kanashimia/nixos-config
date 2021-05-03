{ pkgs, config, lib, ... }:

{
  systemd.package = pkgs.systemd.override { withOomd = true; };
  systemd.additionalUpstreamSystemUnits = [ "systemd-oomd.service" ];
  
  # oomd requires swap to be configured before it can run;
  # need to check for swapDevices mostly so that vm doesn't fail.
  systemd.services.systemd-oomd = {
    wantedBy = lib.mkIf (config.swapDevices != []) [ "multi-user.target" ];
    after = [ "swap.target" ];
    aliases = [ "dbus-org.freedesktop.oom1.service" ];
  };
  
  # ids should be replaced eventually with something sane
  users.groups.systemd-oom.gid = 666;
  users.users.systemd-oom = {
    uid = 666;
    group = "systemd-oom";
    isSystemUser = true; # seems to be required now
  };
 
  systemd.slices."-".sliceConfig.ManagedOOMSwap = "kill";
}
