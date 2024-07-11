{ pkgs, lib, config, ... }: let
  domain = "redpilled.dev";
in {
  services.stalwart-mail = {
    enable = true;
    loadCredential = [ "cool-secret" ];
    settings = {
      config.local-keys = [
        "store.*"
        "directory.*"
        "storage.*"
        "tracer.*"
        "server.*"
        "!server.blocked-ip.*"
        "authentication.fallback-admin.*"
        "cluster.node-id"
        "lookup.default.hostname"
        "report.analysis.*"
        "certificate.*"
        "acme.*"
        "signature.*"
      ];

      signature."rsa-${domain}" = {
        private-key = "%{file:/var/lib/stalwart-mail/rsa}%";
        domain = domain;
        selector = "202404r";
        algorithm = "rsa-sha256";
      };

      signature."ed25519-${domain}" = {
        private-key = "%{file:/var/lib/stalwart-mail/ed}%";
        domain = domain;
        selector = "202404e";
        algorithm = "ed25519-sha256";
      };

      report.analysis = {
        addresses = [ "dmarc-ruf@*" "dmarc-rua@*" "tlsrpt@*" ];
        forward = false;
      };

      queue.outbound.tls = {
        starttls = "optional";
        mta-sts = "optional";
        dane = "optional";
      };

      acme."letsencrypt" = {
        directory = "https://acme-v02.api.letsencrypt.org/directory";
        challenge = "dns-01";
        contact = "acme3@${domain}";
        domains = [ domain ];
        provider = "cloudflare";
        secret = "%{file:/run/credentials/stalwart-mail.service/cool-secret}%";
      };

      authentication = {
        fail2ban = "1000/1d";
        rate-limit = "100/1m";
      };

      resolver = {
        type = "cloudflare";
        concurrency = 2;
        timeout = "10s";
        attempts = 3;
      };

      lookup = {
        default = {
          hostname = domain;
          domain = domain;
        };
        spam-trap = {
          "trans-migrated@*" = "";
          "roqwrqworqw@*" = "";
        };
      };

      server.proxy.trusted-networks = ["127.0.0.1" "::1"];

      server.listener = {
        "imap"      = { bind = "[::]:143";  protocol = "imap";        tls.implicit = false; };
        "imaps"     = { bind = "[::]:993";  protocol = "imap";        tls.implicit = true;  };
        "smtp"      = { bind = "[::]:25";   protocol = "smtp";        tls.implicit = false; };
        "smtp-sub"  = { bind = "[::]:587";  protocol = "smtp";        tls.implicit = false; };
        "smtps-sub" = { bind = "[::]:465";  protocol = "smtp";        tls.implicit = true;  };
        "http"      = { bind = "[::]:8080"; protocol = "http";        tls.implicit = true;  };
        "sieve"     = { bind = "[::]:4190"; protocol = "managesieve"; tls.implicit = true;  };
      };

      storage = {
        blob = "rocksdb";
        data = "rocksdb";
        fts = "rocksdb";
        lookup = "rocksdb";
        directory = "internal";
      };

      directory."internal" = {
        store = "rocksdb";
        type = "internal";
      };

      store."rocksdb" = {
        compression = "lz4";
        path = "/var/lib/stalwart-mail/data";
        type = "rocksdb";
      };

      tracer."stdout" = {
        type = "stdout";
        level = "info";
        ansi = false;
        enable = true;
      };
    };
  };

  environment.systemPackages = [ pkgs.stalwart-mail ];

  networking.firewall.allowedTCPPorts = [
    25 # smtp
    465 # smtp tls
    993 # imap tls
    587 # smtp starttls
    143 # imap starttls
    8080 # stalwart http
    4190 # manage sieve
  ];
}
