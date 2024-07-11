{ config, lib, pkgs, ... }: let
  cfg = config.services.stalwart-mail;
  configFormat = pkgs.formats.toml {};
  configFile = configFormat.generate "stalwart-mail.toml" cfg.settings;
in {
  disabledModules = [ "services/mail/stalwart-mail.nix" ];

  options = {
    services.stalwart-mail = {
      enable = lib.mkEnableOption "Stalwart Mail";
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
    systemd.services."stalwart-mail" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" "network.target" ];

      serviceConfig = {
        LoadCredential = cfg.loadCredential;

        ExecStart = "${lib.getExe pkgs.stalwart-mail} --config=${configFile}";

        Type = "simple";
        Restart = "on-failure";
        RestartSec = 5;
        SyslogIdentifier = "stalwart-mail";

        DynamicUser = true;
        User = "stalwart-mail";
        StateDirectory = "stalwart-mail";

        # Bind standard privileged ports
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

        # Hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = false; # incompatible with CAP_NET_BIND_SERVICE
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
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
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

