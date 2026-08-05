{ config, lib, pkgs, ... }: let
  cfg = config.services.mia.stalwart;

  configFormat = pkgs.formats.json {};
  configFile = configFormat.generate "stalwart-config.json" cfg.datastore;

  planFormat = {
    type = with lib.types; listOf json;
    generate = name: value:
      pkgs.writeText name (lib.concatMapStringsSep "\n" builtins.toJSON value);
  };
  planFile = planFormat.generate "stalwart-plan.ndjson" cfg.plan;
in {
  options = {
    services.mia.stalwart = {
      enable = lib.mkEnableOption "Stalwart";
      datastore = lib.mkOption {
        type = configFormat.type;
        default = {
          "@type" = "RocksDb";
          path = "/var/lib/stalwart/db";
        };
      };
      plan = lib.mkOption {
        type = planFormat.type;
        default = [];
      };
      credentials = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
      };
      env = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = {};
      };
      envFile = lib.mkOption {
        type = with lib.types; oneOf [ path str null ];
        default = "-/var/lib/stalwart/stalwart.env";
      };
      applyEnv = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = {};
      };
      applyEnvFile = lib.mkOption {
        type = with lib.types; oneOf [ path str null ];
        default = "-/var/lib/stalwart/stalwart-apply.env";
      };
      package = lib.mkPackageOption pkgs "stalwart" {
        default = "stalwart_0_16";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."stalwart/plan.ndjson".source = planFile;
    environment.etc."stalwart/config.json".source = configFile;

    # This service stores a potentially large amount of data.
    # Running it as a dynamic user would force chown to be run everytime the
    # service is restarted on a potentially large number of files.
    # That would cause unnecessary and unwanted delays.
    users.users."stalwart" = {
      isSystemUser = true;
      group = "stalwart";
      # stalwart-cli requires a valid home directory,
      # otherwise it fails with EPERM
      home = "/var/lib/stalwart";
    };
    users.groups."stalwart" = {};

    /* systemd.services."stalwart-wait-online" = {
      description = "Wait for Stalwart Server to be Online because this garbage doesn't support sd_notify";

      wantedBy = [ "stalwart.service" ];
      bindsTo = [ "stalwart.service" ];
      after = [ "stalwart.service" ];

      path = [ pkgs.curl ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "stalwart-notify.sh" ''
          PORT="''${STALWART_RECOVERY_MODE_PORT:-8080}"
          URL="http://localhost:$PORT/healthz/ready"
          MAX_ATTEMPTS=10
          SLEEP_INTERVAL=1

          for (( ATTEMPT=1; ; ATTEMPT++ )); do
            if curl --fail -s -o /dev/null --max-time 60 "$URL"; then
              break
            fi

            if (( $ATTEMPT >= $MAX_ATTEMPTS )); then
              echo "Stalwart failed to become healthy after $ATTEMPT attempts, bailing out."
              exit 1
            fi

            echo "Attempt $ATTEMPT/$MAX_ATTEMPTS: Stalwart isn't ready yet (status: $STATUS). Retrying in $SLEEP_INTERVAL seconds."
            sleep "$SLEEP_INTERVAL"
          done
        '';
      };
    }; */

    systemd.services."stalwart-apply-plan" = rec {
      wantedBy = [ "stalwart.service" ];
      bindsTo = [ "stalwart.service" ];
      after = [ "stalwart.service" ];

      path = [ pkgs.curl pkgs.stalwart-cli ];

      environment = {
        STALWART_URL = "http://localhost:8080";
      } // cfg.applyEnv;

      restartTriggers = [ config.environment.etc."stalwart/plan.ndjson".source ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true; # is needed for the restart to work
        LoadCredential = cfg.credentials;
        EnvironmentFile = cfg.applyEnvFile;
        ExecStart = pkgs.writeShellScript "stalwart-notify.sh" ''
          set -e

          MAX_ATTEMPTS=10
          SLEEP_INTERVAL=1

          if [[ -z "$STALWART_URL" ]]; then
            echo "STALWART_URL env var isn't set"
            exit 1
          fi

          for (( ATTEMPT=1; ; ATTEMPT++ )); do
            if curl --fail -s -o /dev/null --max-time 60 "$STALWART_URL/healthz/ready"; then
              break
            fi

            if (( $ATTEMPT >= $MAX_ATTEMPTS )); then
              echo "Stalwart failed to become healthy after $ATTEMPT attempts, bailing out."
              exit 1
            fi

            echo "Attempt $ATTEMPT/$MAX_ATTEMPTS: Stalwart isn't ready yet. Retrying in $SLEEP_INTERVAL seconds."
            sleep "$SLEEP_INTERVAL"
          done

          if [[ -f "$CREDENTIALS_DIRECTORY/stalwart-token" ]]; then
            IFS= read -r STALWART_TOKEN < "$CREDENTIALS_DIRECTORY/stalwart-token"
            export STALWART_TOKEN
            stalwart-cli apply --file /etc/stalwart/plan.ndjson
          else
            echo "No 'stalwart_token' credential found, skipping apply."
          fi
        '';
      };
    };

    systemd.services."stalwart" = let
      stalwart-wrapper = pkgs.stdenv.mkDerivation {
        pname = "stalwart-wrapper";
        version = "0.0.0";
        dontUnpack = true;
        buildPhase = ''
          $CC -O3 ${./stalwart-wrapper.c} -o stalwart-wrapper
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp stalwart-wrapper $out/bin/
        '';
        meta.mainProgram = "stalwart-wrapper";
      };
    in {
      description = "Stalwart Server";

      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" "network.target" ];

      environment = cfg.env;

      serviceConfig = {
        Type = "exec";
        ExecStart = "${lib.getExe stalwart-wrapper} ${lib.getExe cfg.package} --config=/etc/stalwart/config.json";

        EnvironmentFile = cfg.envFile;
        LoadCredential = cfg.credentials;

        Restart = "on-failure";
        RestartSec = 5;

        SyslogIdentifier = "stalwart";

        User = "stalwart";
        Group = "stalwart";

        StateDirectory = "stalwart";
        CacheDirectory = "stalwart";
        StateDirectoryMode = "0750";

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

    # Make admin commands available in the shell
    environment.systemPackages = [
      cfg.package
      pkgs.stalwart-cli
    ];
  };
}
