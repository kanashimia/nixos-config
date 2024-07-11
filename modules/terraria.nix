{ config, lib, pkgs, ... }: let
  cfg = config.services.terraria;
  configFormat = pkgs.formats.keyValue {};
  configFile = configFormat.generate "terraria-config.txt" cfg.settings;
  terrariaFifo = "/run/terraria/terraria.sock";
in {
  disabledModules = [ "services/games/terraria.nix" ];

  options = {
    services.terraria = {
      enable = lib.mkEnableOption "Terraria Server";
      settings = lib.mkOption {
        type = configFormat.type;
        default = {};
      };
      loadCredential = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.sockets.terraria = {
      partOf = [ "terraria.service" ];
      socketConfig = {
        ListenFIFO = terrariaFifo;
        SocketMode = "0660";
        RemoveOnStop = true;
      };
    };

    systemd.services.terraria = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      bindsTo = [ "terraria.socket" ];

      preStop = ''
        [ -p ${terrariaFifo} ] && printf '\nexit\n' > ${terrariaFifo}
      '';

      script = ''
        exec ${lib.getExe pkgs.terraria-server} -config <(
          cat ${configFile}
          printf '\npassword='
          cat /run/credentials/terraria.service/terrarion
        )
      '';

      serviceConfig = {
        User = "terraria";
        DynamicUser = true;

        RuntimeDirectory = "terraria";
        StateDirectory = "terraria";
        StateDirectoryMode = "0750";

        StandardInput = "socket";
        StandardOutput = "journal";
        StandardError = "journal";

        SyslogIdentifier = "terraria";

        KillSignal = "SIGCONT";
        TimeoutStopSec = "1h";

        # Hardening
        CapabilityBoundingSet = "";
        LockPersonality = true;
        PrivateDevices = true;
        ProcSubset = "pid";
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_NETLINK" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@privileged" ];
        UMask = "0077";
      };
    };
  };
}

