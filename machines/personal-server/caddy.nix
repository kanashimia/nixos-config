{ config, lib, inputs, pkgs, ... }: {
  services.caddy = {
    enable = true;
    package = pkgs.caddyWith {
      plugins = [
        { src = "github.com/mholt/caddy-events-exec"; rev = "055bfd2e8b8247533c7a710e11301b7d1645c933"; }
        { src = "github.com/caddy-dns/cloudflare"; rev = "44030f9306f4815aceed3b042c7f3d2c2b110c97"; }
      ];
      caddyRev = "8e0d3e1ec56cd349f02c9d201234c56373688ddd";
      vendorHash = "sha256-cB7YZNqpNiW3KZIIaCNmF6muoypCPEDAn8EB3BmZ22M=";
    };
    configFile = pkgs.writeText "Caddyfile" ''
      {
        email acme2@redpilled.dev
        # auto_https prefer_wildcard
        acme_dns cloudflare {file.{$CREDENTIALS_DIRECTORY}/cool-secret}

        log {
          format console {
            time_key ""
            level_format upper
          }
          level info
        }
      }

      mta-sts.redpilled.dev/.well-known/mta-sts.txt,
      autoconfig.redpilled.dev/.well-known/mail-v1.xml,
      autoconfig.redpilled.dev/.well-known/autoconfig/mail/config-v1.1.xml,
      redpilled.dev/.well-known/jmap {
        reverse_proxy :8080 {
          transport http {
            tls_insecure_skip_verify
            proxy_protocol v2
          }
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
      }

      *.redpilled.dev {
        error "Not Found" 404
        import error-page
      }
    '';
  };

  environment.systemPackages = [ config.services.caddy.package ];

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
