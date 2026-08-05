{ pkgs, lib, config, inputs, ... }: let
  commonVictoriaOptions = [
    "-loggerLevel=WARN" "-loggerDisableTimestamps"
  ];
in {
  services.victorialogs = {
    enable = true;
    listenAddress = ":9428";
    extraOptions = commonVictoriaOptions;
  };

  services.journald.upload = {
    enable = true;
    settings.Upload.URL = "http://localhost:9428/insert/journald";
  };

  services.victoriametrics = {
    enable = true;
    listenAddress = ":8428";
    extraOptions = commonVictoriaOptions ++ [
      "--retentionPeriod=90d"
      "--selfScrapeInterval=5s"
      "--memory.allowedPercent=20"
    ];
  };
  services.vmagent = {
    enable = true;
    remoteWrite.url = "http://localhost:8428/api/v1/write";
    prometheusConfig = {
      scrape_configs = [
        {
          job_name = "node-exporter";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "127.0.0.1:9100" ];
              labels.type = "node-exporter";
            }
          ];
        }
        # {
        #   job_name = "victoriametrics";
        #   static_configs = [
        #     { targets = [ "http://localhost:8428/metrics" ]; }
        #   ];
        # }
        {
          job_name = "victoria-logs";
          static_configs = [
            { targets = [ "http://localhost:9428/metrics" ]; }
          ];
        }
        {
          job_name = "haproxy";
          static_configs = [
            { targets = [ "http://localhost:8405/metrics" ]; }
          ];
        }
        {
          job_name = "grafana";
          static_configs = [
            { targets = [ "http://localhost:9400/metrics" ]; }
          ];
        }
        # {
        #   job_name = "tailscale-node-exporter";
        #   http_sd_configs = [
        #     {
        #       url = "http://localhost:9242";
        #     }
        #   ];
        #   relabel_configs = [
        #     {
        #       source_labels = [ "__meta_tailscale_device_hostname" ];
        #       target_label = "tailscale_hostname";
        #     }
        #     {
        #       source_labels = [ "__meta_tailscale_device_name" ];
        #       target_label = "tailscale_name";
        #     }
        #     {
        #       source_labels = [ "__address__" ];
        #       regex = "(.*)";
        #       replacement = "$1:9100";
        #       target_label = "__address__";
        #     }
        #   ];
        # }
      ];
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "cpu"
      "meminfo"
      "diskstats"
      "filesystem"
      "loadavg"
      "netdev"
      "systemd"
    ];
    listenAddress = "127.0.0.1";
    port = 9100;
  };

  systemd.services.grafana = {
    environment = {
      GOMEMLIMIT = "600MiB";
      GOGC = "50";
      # GF_DIAGNOSTICS_PROFILING_ENABLED = "true";
      # GF_DIAGNOSTICS_PROFILING_ADDR = "0.0.0.0";
      # GF_DIAGNOSTICS_PROFILING_PORT = "6060";
      # GF_DIAGNOSTICS_PROFILING_BLOCK_RATE = "5";
      # GF_DIAGNOSTICS_PROFILING_MUTEX_RATE = "5";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 9400; # default: 3000
        enable_gzip = false;
      };
      log.level = "warn";
      log.mode = "syslog";
      "log.syslog".tag = "grafana";
      "auth.anonymous".enabled = true;
      # auth.disable_login_form = true;
      security.admin_email = "chad@redpilled.dev";
      security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
      analytics.reporting_enabled = false;
      analytics.check_for_updates = false;
      analytics.enabled = false;
      # caching.enabled = false;
      dashboard_cleanup.interval = "30m";
      database.high_availability = false;
      # metrics.enabled = false;
      unified_alerting.enabled = false;
      alerting.enabled = false;
      # feature_toggles.enable = "live";
      # server.enable_pprof = true;
    };

    provision = {
      enable = true;

      # dashboards.settings.providers = [
      #   { name = "Overview"; options.path = "/etc/grafana-dashboards"; }
      # ];

      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "VictoriaMetrics";
            type = "victoriametrics-metrics-datasource";
            access = "proxy";
            url = "http://127.0.0.1:8428";
            isDefault = true;
          }
          {
            name = "VictoriaLogs";
            type = "victoriametrics-logs-datasource";
            access = "proxy";
            url = "http://127.0.0.1:9428";
            isDefault = false;
          }
        ];
      };
    };

    declarativePlugins = with pkgs.grafanaPlugins; [
      victoriametrics-metrics-datasource
      victoriametrics-logs-datasource
    ];
  };
}
