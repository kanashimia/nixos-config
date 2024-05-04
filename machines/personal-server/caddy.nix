{ config, lib, inputs, pkgs, ... }: {
  environment.systemPackages = [ config.services.caddy.package ];

  # Hack to place data in /var/lib/caddy instead of /var/lib/caddy/.local/share/caddy
  systemd.services."caddy".environment = {
    XDG_DATA_HOME = "/var/lib";
    XDG_CONFIG_HOME = "/var/lib";
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddyWith {
      plugins = [
        "github.com/mholt/caddy-events-exec@055bfd2e8b8247533c7a710e11301b7d1645c933"
        "github.com/caddyserver/transform-encoder@f627fc4f76334b7aef8d4ed8c99c7e2bcf94ac7d"
        "github.com/caddy-dns/cloudflare@44030f9306f4815aceed3b042c7f3d2c2b110c97"
      ];
      vendorHash = "sha256-oCD9GtSkugMGccoBe0hA/xGBdesOmTAjmw9S+rHHw5E=";
    };
    logFormat = ''
        format console {
            time_key ""
            level_format upper
        }
        level info
    '';
    globalConfig = ''
      email acme2@redpilled.dev
    '';
    virtualHosts = lib.mapAttrs (k: v: { logFormat = ""; } // v) {
      "redpilled.dev".extraConfig = ''
        root * /srv/www
        file_server
        encode zstd gzip

        reverse_proxy /.well-known/jmap :8080 {
          transport http {
            tls_server_name {host}
          }
        }
      '';
      "mta-sts.redpilled.dev".extraConfig = ''
        respond /.well-known/mta-sts.txt <<EOF
          version: STSv1
          mode: enforce
          mx: redpilled.dev
          max_age: 604800
          EOF
      '';
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      80 # http
      443 # https
      # 53 # dns
    ];
    allowedUDPPorts = [
      80 # http
      443 # https
    ];
  };
}
