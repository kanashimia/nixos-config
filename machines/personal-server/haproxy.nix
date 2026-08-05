{ config, lib, inputs, pkgs, ... }: {
  services.haproxy.enable = true;
  # services.haproxy.config = lib.readFile ./haproxy.cfg;
  services.haproxy.config = "";

  # environment.etc."haproxy.cfg".text = lib.mkForce null;
  environment.etc."haproxy.cfg".enable = false;
  environment.etc."haproxy/haproxy.cfg".source = lib.mkForce ./haproxy.cfg;

  environment.etc."haproxy/mail-routes.lst".text = ''
    mail.redpilled.dev/
    mta-sts.redpilled.dev/.well-known/mta-sts.txt
    autoconfig.redpilled.dev/.well-known/mail-v1.xml
    autoconfig.redpilled.dev/.well-known/autoconfig/mail/config-v1.1.xml
    autoconfig.redpilled.dev/mail/config-v1.1.xml
    autodiscover.redpilled.dev/autodiscover/autodiscover.xml
    redpilled.dev/jmap/
    redpilled.dev/auth/
    redpilled.dev/healthz/
    redpilled.dev/.well-known/oauth-authorization-server
    redpilled.dev/.well-known/openid-configuration
    redpilled.dev/.well-known/jmap
  '';

  environment.etc."haproxy/cloudflare-ips.lst".text = ''
    173.245.48.0/20
    103.21.244.0/22
    103.22.200.0/22
    103.31.4.0/22
    141.101.64.0/18
    108.162.192.0/18
    190.93.240.0/20
    188.114.96.0/20
    197.234.240.0/22
    198.41.128.0/17
    162.158.0.0/15
    104.16.0.0/13
    104.24.0.0/14
    172.64.0.0/13
    131.0.72.0/22
    2400:cb00::/32
    2606:4700::/32
    2803:f800::/32
    2405:b500::/32
    2405:8100::/32
    2a06:98c0::/29
    2c0f:f248::/32
  '';

  # systemd.tmpfiles.rules = [
  #   "d '/var/lib/haproxy' 0700 haproxy haproxy - -"
  # ];

  # systemd.services.haproxy = {
  #   path = [ pkgs.openssl pkgs.socat pkgs.diffutils ];
  #   serviceConfig = {
  #     StateDirectory = "haproxy";
  #     WorkingDirectory = "/var/lib/haproxy";
  #     UMask = "0077";
  #     StateDirectoryMode = "0700";
  #     ExecStartPre = lib.mkForce [
  #       # when the master process receives USR2, it reloads itself using exec(argv[0]),
  #       # so we create a symlink there and update it before reloading
  #       "${pkgs.coreutils}/bin/ln -sf ${pkgs.haproxy}/bin/haproxy /run/haproxy/haproxy"
  #       # when running the config test, don't be quiet so we can see what goes wrong
  #       "/run/haproxy/haproxy -c -f /etc/haproxy.cfg"
  #     ];
  #     ExecStart = lib.mkForce "/run/haproxy/haproxy -Ws -f /etc/haproxy.cfg -p /run/haproxy/haproxy.pid";
  #     # support reloading
  #     ExecReload = lib.mkForce [
  #       "${pkgs.haproxy}/bin/haproxy-dump-certs -v -p . -s /run/haproxy/haproxy.sock"
  #       "${pkgs.haproxy}/bin/haproxy -c -f /etc/haproxy.cfg"
  #       "${pkgs.coreutils}/bin/ln -sf ${pkgs.haproxy}/bin/haproxy /run/haproxy/haproxy"
  #       "${pkgs.coreutils}/bin/kill -USR2 $MAINPID"
  #     ];
  #     ExecStop = lib.mkForce [
  #       "${pkgs.haproxy}/bin/haproxy-dump-certs -v -p . -s /run/haproxy/haproxy.sock"
  #     ];
  #     SystemCallFilter = lib.mkForce [];
  #     PrivateTmp = "disconnected";
  #   };
  #   reloadTriggers = [ config.environment.etc."haproxy.cfg".source ];
  # };

  services.journald.extraConfig = ''
    ForwardToWall=false
  '';
  
  systemd.services.haproxy = lib.mkForce {
    description = "HAProxy";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "haproxy";
      Group = "haproxy";

      RuntimeDirectory = "haproxy";
      StateDirectory = "haproxy";
      WorkingDirectory = "/var/lib/haproxy";
      UMask = "0077";
      StateDirectoryMode = "0700";

      EnvironmentFile = "-/var/lib/haproxy/haproxy.env";

      # ExecStartPre = lib.mkForce [
      #   (pkgs.writeShellScript "haproxy-gen-env.sh" ''
      #     echo "PUBLIC_IPS=$(</etc/credstore/ipv4),$(</etc/credstore/ipv6)" > /run/haproxy/haproxy.env
      #   '')
      # ];
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p auth pki lua maps"
      ];
      ExecStart = lib.mkForce [
        # "${(pkgs.writeShellScriptBin "haproxy" lib.readFile "./log-wrapper.sh")} ${pkgs.haproxy}/bin/haproxy -q -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy/haproxy.pid -S /run/haproxy/haproxy-master.sock"
        # "${pkgs.haproxy}/bin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -f /etc/haproxy/conf.d -p /run/haproxy/haproxy.pid -S /run/haproxy/haproxy-master.sock"
        "${pkgs.haproxy}/bin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy/haproxy.pid -S /run/haproxy/haproxy-master.sock"
      ];
      ExecReload = lib.mkForce [
        "${pkgs.haproxy}/bin/haproxy-dump-certs -p pki -S /run/haproxy/haproxy-master.sock"
        "${pkgs.haproxy}/bin/haproxy-reload -S /run/haproxy/haproxy-master.sock"
      ];
      ExecStop = lib.mkForce [
        "${pkgs.haproxy}/bin/haproxy-dump-certs -p pki -S /run/haproxy/haproxy-master.sock"
      ];

      PrivateTmp = "disconnected";

      KillMode = "mixed";
      Restart = "always";
      SuccessExitStatus = "143";
      Type = "notify";

      AmbientCapabilities = "CAP_NET_BIND_SERVICE";

      NoNewPrivileges = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      SystemCallFilter = "~@cpu-emulation @keyring @module @obsolete @raw-io @reboot @swap @sync";
    };
    path = [ pkgs.openssl pkgs.socat pkgs.diffutils ];
    reloadTriggers = [ config.environment.etc."haproxy/haproxy.cfg".source ];
  };

  networking.firewall.allowedTCPPorts = [
    80 # http
    443 # https
    1337
    1338
    1339
  ];
  networking.firewall.allowedUDPPorts = [
    80 # http quic
    443 # https quic
  ];
}
