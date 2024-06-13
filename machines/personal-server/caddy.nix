{ config, lib, inputs, pkgs, ... }: {
  environment.systemPackages = [ config.services.caddy.package ];

  # Hack to place data in /var/lib/caddy instead of /var/lib/caddy/.local/share/caddy
  systemd.services."caddy".environment = {
    XDG_DATA_HOME = "/var/lib";
    XDG_CONFIG_HOME = "/var/lib";
  };

  systemd.services."caddy".serviceConfig = {
    # SupplementaryGroups = [ "acme" ];
    LoadCredentialEncrypted = "cool-secret:${./secrets/cool-secret.creds}";
  };

  services.caddy = {
    enable = true;
    package = (pkgs.caddyWith {
      plugins = [
        { src = "github.com/mholt/caddy-events-exec"; rev = "055bfd2e8b8247533c7a710e11301b7d1645c933"; }
        { src = "github.com/caddy-dns/cloudflare"; rev = "44030f9306f4815aceed3b042c7f3d2c2b110c97"; }
        # { src = "github.com/dunglas/caddy-cbrotli"; rev = "8beb6ee36d771b2299679a2b6cf48a8e7bb6b7cf"; }
        # { src = "github.com/mliezun/caddy-snake"; rev = "8725bc72230990c450244f00136e579d26ec2e09"; }
        # { src = "github.com/dunglas/frankenphp/caddy"; rev = "469070ce8573fc2cd9453d2559d8b5d9d0fa93fb"; }
        # { src = "github.com/dunglas/mercure/caddy"; rev = "c9f42a623b6b9be6242a46be5370f81d43097b1e"; }
        # { src = "github.com/dunglas/vulcain/caddy"; rev = "f66da22c7234f2cdab1e5d546d37652d5ea38784"; }
      ];
      caddyRev = "8e0d3e1ec56cd349f02c9d201234c56373688ddd";
      vendorHash = "sha256-cB7YZNqpNiW3KZIIaCNmF6muoypCPEDAn8EB3BmZ22M=";
    });
    /* .overrideAttrs (old: let
      phpEmbedWithZts = pkgs.php.override {
      embedSupport = true;
        ztsSupport = true;
        staticSupport = false;
        zendSignalsSupport = false;
        zendMaxExecutionTimersSupport = true;
      };
      phpUnwrapped = phpEmbedWithZts.unwrapped;
      phpConfig = "${phpUnwrapped.dev}/bin/php-config";
      thpool = pkgs.stdenv.mkDerivation {
        pname = "c-thread-pool";
        version = "unstable";
        src = pkgs.fetchFromGitHub {
          owner = "Pithikos";
          repo = "C-Thread-Pool";
          rev = "4eb5a69a439f252d2839af16b98d94464883dfa5";
          hash = "sha256-47bE76Uda1B+9+uW1LwNboWMIQeWntlhg0IxOFDk6EI=";
        };
        # buildPhase = ''
        #   $CC thpool.c -pthread -o hello_nix
        # '';
        installPhase = ''
          mkdir -p $out/lib $out/include/C-Thread-Pool
          cp thpool.h thpool.c $out/include/C-Thread-Pool
        '';
      }
    in {
      nativeBuildInputs = old.nativeBuildInputs ++ [
        pkgs.pkg-config
        pkgs.makeBinaryWrapper
        thpool
      ];

      buildInputs = [ phpUnwrapped pkgs.brotli ] ++ phpUnwrapped.buildInputs;

      preBuild = ''
        export CGO_ENABLED=1
        export XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s'"
        export CGO_CFLAGS="$(${phpConfig} --includes) -I ${thpool}/include"
        export CGO_LDFLAGS="-DFRANKENPHP_VERSION=1.1.5 \
          $(${phpConfig} --ldflags) \
          $(${phpConfig} --libs)"
      '';

      postPatch = ''
        ${pkgs.tree}/bin/tree vendor/github.com/dunglas/frankenphp
      '';

      preFixup = ''
        mkdir -p $out/lib
        ln -s "${phpEmbedWithZts}/lib/php.ini" "$out/lib/frankenphp.ini"

        wrapProgram $out/bin/caddy --set-default PHP_INI_SCAN_DIR $out/lib
      '';

      ldflags = old.ldflags ++ [
        "-X 'github.com/caddyserver/caddy/v2.CustomVersion=FrankenPHP 1.1.5 PHP ${phpUnwrapped.version} Caddy'"
      ];
    });
    */
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

      redpilled.dev {
        file_server
        root * /srv/www
        encode zstd gzip

        handle_errors {
          header Content-Type text/html
          templates
          rewrite * errors.html
          file_server
        }
      }

      *.redpilled.dev {
        respond 404
      }
    '';
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
