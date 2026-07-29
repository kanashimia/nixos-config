{ pkgs, lib, config, ... }: {
  # Documentation slows eval quite a lot.
  documentation.nixos.enable = false;

  # Useless stuff.
  programs.less.lessopen = null;
  documentation.info.enable = false;

  # Some default programs that i always use.
  environment.sessionVariables = {
    EDITOR = "hx";
    LESS = "-RiF --mouse --wheel-lines=3";
    MANWIDTH = "90";
    MANOPT = "--nj --nh";
  };
  environment.defaultPackages = with pkgs; [
    git kakoune rsync helix
  ];

  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/lru_gen/min_ttl_ms - - - - 1000"
    "w /sys/kernel/mm/transparent_hugepage/enabled - - - - always"
    "w /sys/kernel/mm/transparent_hugepage/shmem_enabled - - - - advise"
    # "w /sys/kernel/mm/transparent_hugepage/khugepaged/defrag - - - - 1"
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
    "w /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 0"
  ];

  # Locale and keymaps
  console.keyMap = "dvorak";
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "dvorak";
  time.timeZone = "Europe/Kyiv";
  i18n = {
    supportedLocales = [ "all" ];
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings = {
      LC_COLLATE = "C.UTF-8";
    };
  };

  systemd.additionalUpstreamSystemUnits = [
     "systemd-imdsd@.service"
     "systemd-imdsd.socket"
     "systemd-imds-import.service"
     "systemd-imds-early-network.service"
  ];
  boot.initrd.systemd.additionalUpstreamUnits = [
     "systemd-imdsd@.service"
     "systemd-imdsd.socket"
     "systemd-imds-import.service"
     "systemd-imds-early-network.service"
  ];
  # systemd.sockets.systemd-networkd-varlink-metrics.wantedBy = [ "sockets.target" ];
  boot.initrd.systemd.storePaths = [
    "${config.systemd.package}/lib/systemd/systemd-imds"
  ];
  users.users.systemd-imds = {
    description = "systemd Instance Metadata";
    isSystemUser = true;
    group = "systemd-imds";
    # createHome  = true;
    # uid         = config.ids.uids.terraria;
  };
  users.groups.systemd-imds = {
    # gid = config.ids.gids.terraria;
  };

}
