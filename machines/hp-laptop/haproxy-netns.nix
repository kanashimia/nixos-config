{ pkgs, lib, config, ... }:
{
  systemd.services."netns@" = {
    # overrideStrategy = "asDropin";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = [
        "${pkgs.iproute2}/bin/ip netns add %I"
        "${pkgs.iproute2}/bin/ip -n %I link set dev lo up"
      ];
      ExecStop = [
        "${pkgs.iproute2}/bin/ip netns del %I"
      ];

      # User = "haproxy";
      # Group = "haproxy";
      # WorkingDirectory = "/var/run/netns";
      # ExecStart = [
      #   "/run/current-system/sw/bin/touch /var/run/netns/%I"
      #   "/run/current-system/sw/bin/chown haproxy:haproxy /var/run/netns/%I"
      #   "/run/current-system/sw/bin/unshare --net=/var/run/netns/%I /run/current-system/sw/bin/true"
      #   "/run/current-system/sw/bin/chown haproxy:haproxy /var/run/netns/%I"
      # ];
      # ExecStop = [
      #   "/run/current-system/sw/bin/umount /var/run/netns/%I"
      # ];
      # AmbientCapabilities = "CAP_NET_BIND_SERVICE CAP_NET_ADMIN CAP_NET_RAW CAP_SYS_ADMIN";

    };
    path = [ "/run/current-system/sw/bin" ];
  };

  systemd.services."netns@caddy" = {
    overrideStrategy = "asDropin";
  };


  systemd.services."caddy" = {
    bindsTo = [ "netns@caddy.service" ];
    after = [ "netns@caddy.service" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/caddy";
    };
  };

  services.haproxy.enable = true;
  services.haproxy.config = ''
    global
      maxconn     256
      log stderr format short daemon
      # user haproxy
      # group haproxy
      # chroot /var/empty
      # setcap cap_sys_admin

    defaults
      mode http
      log global
      option httplog

    listen servers
      bind *:8001
      server directory-server 127.0.0.1:8000 namespace caddy
      # http-request return status 418 content-type "text/plain" lf-string "ERR not FOUND" 
  '';

  systemd.services.haproxy = lib.mkForce {
    description = "HAProxy";
    after = [ "network.target" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "haproxy";
      Group = "haproxy";

      StateDirectory = "haproxy";
      WorkingDirectory = "/var/lib/haproxy";
      RuntimeDirectory = "haproxy";
      UMask = "0077";
      StateDirectoryMode = "0700";
      
      # SocketBindAllow = 81;
      # SocketBindDeny = "any";

      ExecStart = lib.mkForce [
        "${pkgs.haproxy}/bin/haproxy -Ws -f /etc/haproxy.cfg -p /run/haproxy/haproxy.pid -S /run/haproxy/haproxy-master.sock"
      ];
      ExecReload = lib.mkForce [
        "${pkgs.haproxy}/bin/haproxy-reload -S /run/haproxy/haproxy-master.sock"
      ];
      ExecStop = lib.mkForce [
      ];

      PrivateTmp = "disconnected";

      KillMode = "mixed";
      Restart = "always";
      SuccessExitStatus = "143";
      Type = "notify";

      AmbientCapabilities = "CAP_NET_BIND_SERVICE CAP_SYS_ADMIN";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_NET_ADMIN CAP_NET_RAW CAP_SYS_ADMIN";

      # SystemCallFilter = "@system-service ~@priviliged"
      # SystemCallFilter = "~@priviliged @cpu-emulation @debug @mount @obsolete @pkey @resources @sandbox @setuid"

      # SystemCallFilter = [ "@system-service" "~@chown @keyring @memlock @privileged @resources" ];
      SystemCallFilter = [ "@system-service" "~@aio @chown @sync @keyring @memlock @setuid @privileged" ];
      # SystemCallErrorNumber = "EPERM";

      NoNewPrivileges = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;

      ProcSubset = "pid";
      ProtectProc = "invisible";
      RestrictSUIDSGID = true;
      RestrictNamespaces = "net";
      RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
      ProtectKernelLogs = true;
      ProtectClock = true;
      PrivateDevices = true;
      LockPersonality = true;
      RemoveIPC = true;
      MemoryDenyWriteExecute = true;
      SystemCallArchitectures = "native";
      RestrictRealtime = true;
      BindReadOnlyPaths = "/etc/haproxy.cfg /nix/store /var/run/netns";
      RootDirectory = "/var/lib/haproxy";
      MountAPIVFS = true;
      ProtectHostname = true;

      # AmbientCapabilities = "CAP_NET_BIND_SERVICE CAP_NET_ADMIN CAP_NET_RAW CAP_SYS_ADMIN";
      # CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_NET_ADMIN CAP_NET_RAW CAP_SYS_ADMIN";
    };
    path = [ pkgs.openssl pkgs.socat pkgs.diffutils ];
    reloadTriggers = [ config.environment.etc."haproxy.cfg".source ];
  };


  services.caddy.enable = true;
  services.caddy.extraConfig = ''
    lmao.redpilled.dev {
      encode zstd gzip
      file_server
      root /srv
    }
    :8000 {
      encode zstd gzip
      file_server
      root /srv
    }
  '';
}
