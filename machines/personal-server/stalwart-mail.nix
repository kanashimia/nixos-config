{ pkgs, lib, config, ... }: let
  domain = "redpilled.dev";
  hostname = "mail.redpilled.dev";
  stalwartIp = "127.0.1.4"; 
in {
  networking.hosts = {
    ${stalwartIp} = [ "stalwart.internal" ];
  };

  services.mia.stalwart = let
    destroy = object: value: { "@type" = "destroy"; inherit object value; };
    update = object: value: { "@type" = "update"; inherit object value; };
    updateId = object: id: value: { "@type" = "update"; inherit object value id; };
    create = object: value: { "@type" = "create"; inherit object value; };
    upsert = object: matchOn: value: { "@type" = "upsert"; inherit object value matchOn; };
    upsert' = object: value: { "@type" = "upsert"; inherit object value; };
    reconcile = object: matchOn: value: { "@type" = "reconcile"; inherit object value matchOn; };
    # ^ use this when it is ready
    variant = type: value: { "@type" = type; } // value;
    set = values: lib.genAttrs values (_: true);
  in {
    enable = true;
    credentials = [
      "stalwart-token"
    ];
    applyEnv = {
      STALWART_URL = "https://mail.redpilled.dev";
    };
    plan = [
      # (update "SpamSettings" {
      #   spamFilterRulesUrl = "file://${pkgs.stalwart_0_16.spam-filter}";
      # })
      # (destroy "Application" {})
      # (create "Application" {
      #   "app-a" = {
      #     enabled = true;
      #     description = "Stalwart Web Application";
      #     resourceUrl = "https://github.com/stalwartlabs/webui/releases/latest/download/webui.zip";
      #     urlPrefix = {
      #       "/admin" = true;
      #       "/account" = true;
      #     };
      #   };
      # })
      (destroy "Tracer" {})
      (create "Tracer" {
        "tracer-a" = variant "Stdout" {
          level = "info";
          ansi = false;
        };
      })
      (upsert "Domain" ["name"] {
        "dom-a" = {
          name = domain;
          catchAllAddress = "chad@${domain}";
        };
      })
      (update "SystemSettings" {
        defaultDomainId = "#dom-a";
        defaultHostname = hostname;
        proxyTrustedNetworks = set ["127.0.0.0/8" "::1"];
      })
      (upsert "Account" ["name"] {
        "acc-a" = variant "User" {
          domainId = "#dom-a";
          name = "chad";
          roles = variant "Admin" {};
        };
      })
      (reconcile "NetworkListener" ["name"] {
        # "nl-a" = { name = "http-priv";   protocol = "http";        bind = set ["${stalwartIp}:8080"];  tlsImplicit = false; };
        "nl-b" = { name = "http";        protocol = "http";        bind = set ["${stalwartIp}:10080"]; tlsImplicit = false; };
        "nl-c" = { name = "sieve";       protocol = "manageSieve"; bind = set ["${stalwartIp}:14190"]; tlsImplicit = false; };
        # "nl-d" = { name = "pop3s";       protocol = "pop3";        bind = set ["${stalwartIp}:10995"]; tlsImplicit = true;  };
        # "nl-0" = { name = "imap";        protocol = "imap";        bind = set ["${stalwartIp}:10143"]; tlsImplicit = false; };
        "nl-e" = { name = "imaps";       protocol = "imap";        bind = set ["${stalwartIp}:10993"]; tlsImplicit = true;  };
        "nl-f" = { name = "submissions"; protocol = "smtp";        bind = set ["${stalwartIp}:10465"]; tlsImplicit = true;  };
        # "nl-1" = { name = "submission";  protocol = "smtp";        bind = set ["${stalwartIp}:10587"]; tlsImplicit = false; };
        "nl-g" = { name = "smtp";        protocol = "smtp";        bind = set ["${stalwartIp}:10025"]; tlsImplicit = false; };
      })

      (destroy "MemoryLookupKey" { namespace = "spam-traps"; })
      (upsert "MemoryLookupKey" ["namespace" "key"] {
        "lk-a" = { namespace = "spam-traps"; key = "trans-migrated@*"; isGlobPattern = true; };
        "lk-b" = { namespace = "spam-traps"; key = "info@*";           isGlobPattern = true; };
        "lk-c" = { namespace = "spam-traps"; key = "roqwrqworqw@*";    isGlobPattern = true; };
        "lk-d" = { namespace = "spam-traps"; key = "u003cchad@*";      isGlobPattern = true; };
      })

      (upsert "AcmeProvider" ["directory"] {
        "acme-a" = {
          directory = "https://acme-v02.api.letsencrypt.org/directory";
          challengeType = "Http01";
          contact = set ["chad@${domain}"];
        };
      })
      (updateId "Domain" "#dom-a" {
        certificateManagement = variant "Automatic" {
          acmeProviderId = "#acme-a";
          subjectAlternativeNames = set [hostname];
        };
      })

      # (destroy "DkimSignature" {})

      # example destroy:
      # (destroy "Account" { name = "admin2"; })
    ];
  };

  services.mia.stalwart-mail = {
    enable = false;
    loadCredential = [ "cool-secret" "cool-eab-hmac" "cool-eab-kid" ];
    settings = {
      config.local-keys = [
        "store.*"
        "directory.*"
        "storage.*"
        "tracer.*"
        "server.*"
        "http.*"
        # "!server.blocked-ip.*"
        "server.hostname"
        "server.listener.*"
        "server.auto-ban.*"
        "spam-filter.auto-update"
        "spam-filter.score.discard"
        "session.mail.is-allowed"
        # "spam-filter.*"
        "authentication.*"
        "authentication.fallback-admin.*"
        "cluster.node-id"
        "lookup.*"
        "resolver.*"
        "report.analysis.*"
        "report.dmarc.aggregate.send"
        "queue.outbound.*"
        "certificate.*"
        "acme.*"
        "!acme.*.account-key"
        "!acme.*.cert"
        "signature.*"
        "webadmin.resource"
        "spam-filter.resource"
        "webadmin.path"
      ];

      # config.local-keys = [
      #   "store.*"
      #   "directory.*"
      #   "tracer.*"
      #   "!server.blocked-ip.*"
      #   "!server.allowed-ip.*"
      #   "server.*"
      #   "authentication.fallback-admin.*"
      #   "cluster.*"
      #   "config.local-keys.*"
      #   "storage.data"
      #   "storage.blob"
      #   "storage.lookup"
      #   "storage.fts"
      #   "storage.directory"
      #   "certificate.*"
      # ];

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
        addresses = [ "postmaster@*" "dmarc-ruf@*" "dmarc-rua@*" "tlsrpt@*" ];
        forward = false;
      };

      report.dmarc.aggregate = {
        send = "never";
      };

      queue.outbound.tls = {
        starttls = "optional";
        mta-sts = "optional";
        dane = "optional";
      };

      # acme."letsencrypt" = {
      #   directory = "https://acme-v02.api.letsencrypt.org/directory";
      #   challenge = "dns-01";
      #   contact = "acme3@${domain}";
      #   domains = [ hostname ];
      #   provider = "cloudflare";
      #   secret = "%{file:/run/credentials/stalwart-mail.service/cool-secret}%";
      # };

      acme."letsencrypt2" = {
        directory = "https://acme-v02.api.letsencrypt.org/directory";
        challenge = "http-01";
        contact = "acme3@${domain}";
        domains = [ hostname ];
      };

      # acme."zerossl" = {
      #   directory = "https://acme.zerossl.com/v2/DV90";
      #   challenge = "dns-01";
      #   contact = "zerossl@${domain}";
      #   domains = [ hostname ];
      #   provider = "cloudflare";
      #   secret = "%{file:/run/credentials/stalwart-mail.service/cool-secret}%";
      #   eab.kid = "%{file:/run/credentials/stalwart-mail.service/cool-eab-kid}%";
      #   eab.hmac-key = "%{file:/run/credentials/stalwart-mail.service/cool-eab-hmac}%";
      # };

      authentication = {
        fail2ban = "200/1d";
      };

      server.auto-ban = {
        abuse.rate = "60/1d";
        loiter.rate = "300/1d";
      };

      resolver = {
        type = "cloudflare";
        concurrency = 2;
        timeout = "10s";
        attempts = 3;
      };

      lookup = {
        default = {
          domain = domain;
        };
        spam-traps = {
          "trans-migrated@*" = true;
          "info@*" = true;
          "roqwrqworqw@*" = true;
          "u003cchad@*" = true;
        };
        spam-block-addresses = {
          "marketing@github.com" = true;
        };
        # spam-block = {
        #   "marketing@github.com" = true;
        # };
        # blocked-domains = {
        #   "marketing@github.com" = true;
        # };
      };

      spam-filter = {
        score.discard = "15.0";
        auto-update = true;
      };

      session.mail.is-allowed = /*js*/''
        !is_empty(authenticated_as)
        || (
          !key_exists('spam-block', sender_domain)
          && !key_exists('spam-block-addresses', sender)
        )
      '';

      server.hostname = "mail.redpilled.dev";

      server.listener = {
        "imap"      = { bind = "[::]:143";   protocol = "imap";        tls.implicit = false; };
        "imaps"     = { bind = "[::]:993";   protocol = "imap";        tls.implicit = true;  };
        "smtp"      = { bind = "[::]:25";    protocol = "smtp";        tls.implicit = false; };
        "smtp-sub"  = { bind = "[::]:587";   protocol = "smtp";        tls.implicit = false; };
        "smtps-sub" = { bind = "[::]:465";   protocol = "smtp";        tls.implicit = true;  };
        "http-priv" = { bind = "[::]:10081"; protocol = "http";        tls.implicit = false; proxy.trusted-networks = ["127.0.0.0/8" "::1"]; };
        "http"      = { bind = "[::]:10080"; protocol = "http";        tls.implicit = false; proxy.trusted-networks = ["127.0.0.0/8" "::1"]; };
        # "http"      = { bind = "[::]:10443"; protocol = "http";        tls.implicit = true;  };
        "sieve"     = { bind = "[::]:4190";  protocol = "managesieve"; tls.implicit = false;  };
      };

              # || matches(
              #   '^/(jmap|.well-known|auth|mail|autodiscover|metrics|form|healthz|robots.txt)',
              #   url_path
              # )

              # || starts_with(url_path, "/jmap")
              # || starts_with(url_path, "/.well-known")
              # || starts_with(url_path, "/auth")
              # || starts_with(url_path, "/mail")
              # || starts_with(url_path, "/autodiscover")
              # || starts_with(url_path, "/form")
              # || starts_with(url_path, "/healthz")
              # || url_path == "/robots.txt"

      http = {
        # url = "protocol + '://' + config_get('server.hostname')";
        url = "'https://' + config_get('server.hostname')";
        permissive-cors = true;
        headers = [
          # "Cache-Control: private, max-age=3600"
          # "Cache-Control: private, max-age=10, must-revalidate, stale-if-error=86400"
          "Server: Cringe Enterprise"
        ];
        # hsts = true;
        allowed-endpoint = [
          {
            "if" = builtins.replaceStrings ["\n"] [""] /*js*/''
              listener == 'http-priv'
              || contains(
                [
                  'jmap',
                  '.well-known',
                  'auth',
                  'mail',
                  'autodiscover',
                  'metrics',
                  'form',
                  'healthz',
                  'robots.txt'
                ],
                split(url_path, '/')[1]
              )
              || remote_ip == '127.0.0.1'
              || remote_ip == '::ffff:127.0.0.1'
              || remote_ip == '2a01:4f8:1c1c:260a::1'
              || remote_ip == '195.201.40.199'
              || remote_ip == '::1'
              || starts_with(remote_ip, '127.')
              || starts_with(remote_ip, '10.0.')
              || starts_with(remote_ip, '100.')
            '';
            "then" = "200";
          }
          { "else" = "403"; }
        ];
      };

      # session.mail.is-allowed = /*js*/''
      #   !is_empty(authenticated_as)
      #   || (
      #     !is_empty(sender_domain)
      #     && !is_local_domain("", sender_domain)
      #     && !key_exists('spam-block', sender_domain)
      #   )
      # '';

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

      resolver.public-suffix = [
        "file://${pkgs.publicsuffix-list}/share/publicsuffix/public_suffix_list.dat"
      ];
      spam-filter.resource = "file://${pkgs.stalwart_0_15.spam-filter}/spam-filter.toml";
      webadmin = {
        path = "/var/cache/stalwart-mail";
        resource = "file://${pkgs.stalwart_0_15.webadmin}/webadmin.zip";
      };
    };
  };

  environment.systemPackages = [ pkgs.stalwart_0_15 ];

  networking.firewall.allowedTCPPorts = [
    25 # smtp
    465 # smtp tls
    993 # imap tls
    # 587 # smtp starttls
    # 143 # imap starttls
    # 10443 # stalwart http
    4190 # manage sieve
  ];
}
