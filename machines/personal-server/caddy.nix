{ config, lib, inputs, pkgs, ... }: {
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        # "github.com/mholt/caddy-l4@3c6cc2c0ee0875899fde271fbdef95be3fef7a92"
        "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e"
      ];
      hash = "sha256-JVkUkDKdat4aALJHQCq1zorJivVCdyBT+7UhqTvaFLw=";
      # caddyRev = "eaaa2e5872ef9e845a50c6aade36676c0ecfe2e2";
      # vendorHash = "sha256-krnqpb10TeGsYLD1p7u9EuP2EfCQjw0PZhky7fPRylY=";
    };
    configFile = pkgs.writeText "Caddyfile" ''
      {
        email acme2@redpilled.dev
        auto_https prefer_wildcard
        acme_dns cloudflare {file.{$CREDENTIALS_DIRECTORY}/cool-secret}

        log {
          level info
        }
      }

      mta-sts.redpilled.dev/.well-known/mta-sts.txt,
      autoconfig.redpilled.dev/.well-known/mail-v1.xml,
      autoconfig.redpilled.dev/.well-known/autoconfig/mail/config-v1.1.xml,
      autoconfig.redpilled.dev/mail/config-v1.1.xml,
      autodiscover.redpilled.dev/autodiscover/autodiscover.xml,
      redpilled.dev/jmap/*,
      redpilled.dev/auth/*,
      redpilled.dev/healthz/*,
      redpilled.dev/.well-known/oauth-authorization-server,
      redpilled.dev/.well-known/openid-configuration,
      redpilled.dev/.well-known/jmap {
        reverse_proxy :10443 {
          transport http {
            tls_insecure_skip_verify
            proxy_protocol v2
          }
        }
      }

      mail.redpilled.dev {
        reverse_proxy :10443 {
          transport http {
            tls_insecure_skip_verify
            proxy_protocol v2
          }
        }
      }

      (cache) {
        header {
          ?Cache-Control "public, max-age=60, stale-while-revalidate=86400, stale-if-error=86400"
        }
      }

      (error-page) {
        handle_errors {
          encode zstd gzip
          file_server
          root /srv/www
          rewrite /errors.html
          templates
        }
      }

      redpilled.dev {
        encode zstd gzip
        file_server
        root /srv/www
        import error-page
        import cache
      }

      www.redpilled.dev {
      	redir https://redpilled.dev{uri} permanent
      }

      *.redpilled.dev {
        error "Not Found" 404
        import error-page
        import cache
      }
    '';
  };

  environment.systemPackages = [ config.services.caddy.package ];

  systemd.services.caddy.serviceConfig.Type = "exec";
  systemd.services.caddy.serviceConfig.ExecStart = let
    script = pkgs.writeShellScriptBin "caddy-start" ''
      set -e
      ${config.services.caddy.package}/bin/caddy run --config /etc/caddy/caddy_config --adapter caddyfile 2>&1 \
        | ${pkgs.jq}/bin/jq '"<\({error:3,warn:4,info:6,debug:7}[.level]//4)>\(if .logger then "[\(.logger)] " else "" end)\(.msg) \(del(.msg,.level,.ts,.logger) | if . == {} then "" end)"' -r --unbuffered \
        | systemd-cat --level-prefix=true -t caddy
    '';
  in lib.mkForce [ "" "${script}/bin/caddy-start" ];

  # Hack to place data in /var/lib/caddy instead of /var/lib/caddy/.local/share/caddy
  systemd.services."caddy".environment = {
    XDG_DATA_HOME = "/var/lib";
    XDG_CONFIG_HOME = "/var/lib";
  };

  systemd.services."caddy".serviceConfig = {
    LoadCredential = "cool-secret";
  };

  networking.firewall.allowedTCPPorts = [
    80 # http
    443 # https
  ];
  networking.firewall.allowedUDPPorts = [
    80 # http quic
    443 # https quic
  ];
}
