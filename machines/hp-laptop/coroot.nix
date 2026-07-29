{ pkgs, lib, config, inputs, ... }: {
  services.clickhouse = {
    enable = true;
    serverConfig = {
      http_port = 8123;
      tcp_port = 9100;
    };
    usersConfig = {
      profiles = {};
      users = {
        default = {
          profile = "default";
          password = "assword";
        };
      };
    };
  };
  systemd.services."coroot" = {
    enable = true;
    description = "Coroot";
    documentation = ["https://docs.coroot.com"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = let
      conf = (pkgs.formats.yaml {}).generate "coroot.yaml" {
        auth.anonymous_role = "Admin";

        projects = [{
          name = "default";
          apiKeys = [{ key = "randomstring"; }];
        }];

        global_prometheus = {
          # url = "http://localhost:8428/prometheus";
          url = "http://localhost:8428";
          refresh_interval = "15s";
          remote_write_url = "http://localhost:8428/api/v1/write";

          # user = "default";                 # The username for the ClickHouse server.
          # password = "assword";
          # database = "default";             # The initial database on the ClickHouse server.
          use_clickhouse = true;
        };

        global_clickhouse = {
          address = "127.0.0.1:9100";
          user = "default";                 # The username for the ClickHouse server.
          password = "assword";
          database = "default";             # The initial database on the ClickHouse server.
          tls_enable = false;      # Whether TLS is enabled for the ClickHouse server connection.
          tls_skip_verify = false; # Whether to skip verification of the ClickHouse server's TLS certificate.
        };
      };
    in {
      Type = "exec";
      ExecStart = "${pkgs.coroot.overrideAttrs (old: rec {
        version = "1.17.6";
        src = pkgs.fetchFromGitHub {
          owner = "coroot";
          repo = "coroot";
          rev = "v${version}";
          hash = "sha256-MeHRWrRGvp5oOSiMXtXNMZtKA6Q2577ty47HOxtBGJk=";
        };

        vendorHash = "sha256-DCdrE8UYkuUN+rUuxVSGbAnAeLivZ2Xp8xjM+56ZF+A=";
        npmDeps = pkgs.fetchNpmDeps {
          src = "${src}/front";
          hash = "sha256-6a8eOPgAdpZpdXmrHVw/twfikjjWHSy/BdYdlyRQkjc=";
        };
      })}/bin/coroot --data-dir=/var/lib/coroot --listen=0.0.0.0:7080 --config=${conf}";
      StateDirectory = "coroot";
      # EnvironmentFile=-/etc/default/%N -/etc/sysconfig/%N -${FILE_ENV}
      KillMode = "process";
      Delegate = "yes";
      # Having non-zero Limit*s causes performance problems due to accounting overhead
      # in the kernel. We recommend using cgroups to do container-local accounting.
      LimitNOFILE = "1048576";
      LimitNPROC = "infinity";
      LimitCORE = "infinity";
      TasksMax = "infinity";
      TimeoutStartSec = "0";
      Restart = "always";
      RestartSec = "5s";

      # User = "coroot";
    };
  };

  systemd.services."coroot-node-agent" = {
    enable = true;
    description = "Coroot Node Agent";
    documentation = ["https://docs.coroot.com"];
    wants = ["network-online.target" "systemd-journald.socket"];
    after = ["network-online.target" "systemd-journald.socket"];
    wantedBy = ["multi-user.target"];
    environment.LD_LIBRARY_PATH = "${pkgs.systemdLibs}/lib";
    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.coroot-node-agent.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ pkgs.systemdLibs ];
        ldflags = [
          "-extldflags='-Wl,-z,lazy'"
          "-X 'github.com/coroot/coroot-node-agent/flags.Version=${old.version}'"
        ];
      })}/bin/coroot-node-agent --listen=0.0.0.0:7079 --api-key=randomstring --collector-endpoint=http://127.0.0.1:7080 --scrape-interval=10s";
      # StateDirectory = "coroot-node-agent";
      # EnvironmentFile=-/etc/default/%N -/etc/sysconfig/%N -${FILE_ENV}
      KillMode = "process";
      Delegate = "yes";
      # Having non-zero Limit*s causes performance problems due to accounting overhead
      # in the kernel. We recommend using cgroups to do container-local accounting.
      LimitNOFILE = "1048576";
      LimitNPROC = "infinity";
      LimitCORE = "infinity";
      TasksMax = "infinity";
      TimeoutStartSec = "0";
      Restart = "always";
      RestartSec = "5s";

      # DynamicUser = true;
      ProtectSystem = false;
      PrivateTmp = false;

      # User = "coroot";
      # StateDirectory = "coroot-node-agent";

      SupplementaryGroups = "systemd-journal";
    };
  };

  users.users.coroot = {
    group = "coroot";
    extraGroups = ["systemd-journal"];
    isSystemUser = true;
  };

  users.groups.coroot = { };
}
