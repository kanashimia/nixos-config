{ lib, pkgs, ... }: {
  systemd.services.opentelemetry-collector = {
    serviceConfig = {
      SupplementaryGroups = "systemd-journal";
    };
  };
  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;
    settings = {
      receivers = {
        "otlp" = {
          protocols.grpc.endpoint = "localhost:4317";
        };
        "journald" = {
          directory = "/var/log/journal";
        };
      };
      exporters = {
        # "otlp/openobserve" = {
        #   endpoint = "localhost:5081";
        #   headers = {
        #     Authorization = "Basic b2JzZXJ2ZUByZWRwaWxsZWQuZGV2OmhJMTNaSmJhWng1SmtzeUQ=";
        #     organization = "default";
        #     stream-name = "default";
        #   };
        #   tls.insecure = true;
        # };
        "otlphttp/openobserve" = {
          endpoint = "http://localhost:5080/api/default/";
          headers = {
            Authorization = "Basic b2JzZXJ2ZUByZWRwaWxsZWQuZGV2OlJ0THdGams0d0plSE04YVM=";
            stream-name = "default";
          };
        };
      };
      processors = {
        transform = {
          log_statements = [
            {
              context = "log";
              statements = [
                ''set(severity_text, "debug") where Int(body["PRIORITY"]) >= 7''
                ''set(severity_text, "info") where Int(body["PRIORITY"]) == 6''
                ''set(severity_text, "notice") where Int(body["PRIORITY"]) == 5''
                ''set(severity_text, "warn") where Int(body["PRIORITY"]) == 4''
                ''set(severity_text, "error") where Int(body["PRIORITY"]) == 3''
                ''set(severity_text, "fatal") where Int(body["PRIORITY"]) <= 2''
                ''set(resource.attributes["process.pid"], body["_PID"])''
                ''set(resource.attributes["process.command_line"], body["_CMDLINE"])''
                ''set(resource.attributes["process.command"], body["_COMM"])''
                ''set(resource.attributes["process.executable.path"], body["_EXE"])''
                ''set(body, body["MESSAGE"])''
              ];
            }
          ];
        };
      };

      # telemetry = {
      #   logs = {
      #     level = "info";
      #     encoding = "json";
      #     output_paths = ["stdout"];
      #     error_output_paths = ["stdout"];
      #   };
      #   metrics = {
      #     address = "localhost:8888";
      #   };
      # };

      # extensions = {
      #   "basicauth/client" = {
      #     client_auth = {
      #       username = "observe@redpilled.dev";
      #       password = "lmaopass2";
      #     };
      #   };
      # };
      service = {
        # extensions = ["basicauth/client"];
        extensions = [];
        pipelines = {
          logs = {
            receivers = ["otlp" "journald"];
            processors = ["transform"];
            exporters = ["otlphttp/openobserve"];
          };
          traces = {
            receivers = ["otlp"];
            processors = [];
            exporters = ["otlphttp/openobserve"];
          };
        };
      };
    };
  };

  # services.grafana = {
  #   enable = true;
  #   settings = {
  #     server = {
  #       http_addr = "localhost";
  #       http_port = 3000;
  #       domain = "redpilled.dev";
  #       # root_url = "https://your.domain/grafana/"; # Not needed if it is `https://your.domain/`
  #       # serve_from_sub_path = true;
  #     };
  #     plugins = {
  #       enable_alpha = true;
  #       app_tls_skip_verify_insecure = false;
  #       allow_loading_unsigned_plugins = "zinclabs_openobserve";
  #     };
  #   };
  # };

  systemd.services."openobserve" = {
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" "network.target" ];

    environment = {
      ZO_ROOT_USER_EMAIL = "observe@redpilled.dev";
      ZO_ROOT_USER_PASSWORD = "lmaopass";
      ZO_DATA_DIR = "/var/lib/openobserve";
      RUST_LOG = "warn";
    };

    serviceConfig = {
      ExecStart = lib.getExe pkgs.openobserve;

      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
      SyslogIdentifier = "openobserve";

      DynamicUser = true;
      User = "openobserve";
      StateDirectory = "openobserve";

      # Hardening
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      PrivateDevices = true;
      PrivateUsers = false;
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
}
