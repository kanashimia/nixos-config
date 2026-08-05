{ pkgs, lib, config, ... }: let
  domain = "redpilled.dev";
  hostname = "mail.redpilled.dev";
  stalwartIp = "127.0.1.4";

  # webui = pkgs.stalwart_0_16.passthru.webui.overrideAttrs (old: {
  #   nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.zip ];
  #   installPhase = ''
  #     runHook preInstall
  #     mkdir -p $out
  #     cd dist
  #     zip -r $out/webui.zip *
  #     cd ..
  #     runHook postInstall
  #   '';
  # });
in {
  networking.hosts = {
    ${stalwartIp} = [ "stalwart.internal" ];
  };

  services.mia.stalwart = {
    enable = true;
    credentials = [
      "stalwart-token"
    ];
    applyEnv = {
      STALWART_URL = "https://${hostname}";
    };
    plan = let
      autoRefObjects = prefix: objects:
        lib.listToAttrs (lib.imap0 (i: v: { name = "${prefix}-${toString i}"; value = v; }) objects);
      op = type: object: value: {
        "@type" = type;
        object = object;
        value = if lib.isList value then autoRefObjects object value else value;
      };
      destroy = op "destroy";
      create = op "create";
      update = op "update";
      upsertDef = op "upsert";
      updateId = object: id: value:
        op "update" object value // { inherit id; };
      upsert = object: matchOn: value:
        op "upsert" object value // { inherit matchOn; };
      reconcile = object: matchOn: value:
        op "reconcile" object value // { inherit matchOn; };
      variant = type: value: { "@type" = type; } // value;
      set = values: lib.genAttrs values (_: true);
      id = refName: "#${refName}";

      domRef = "dom-a";
      acmeRef = "acme-a";
    in [
      # (update "SpamSettings" {
      #   # spamFilterRulesUrl = "https://github.com/stalwartlabs/spam-filter/releases/latest/download/spam-filter-rules.json.gz";
      #   spamFilterRulesUrl = "file://${pkgs.stalwart_0_16.spam-filter}/spam-filter-rules.json.gz";
      # })
      # (reconcile "Application" ["resourceUrl"] {
      #   "app-a" = {
      #     enabled = true;
      #     description = "Stalwart Web Application";
      #     # resourceUrl = "https://github.com/stalwartlabs/webui/releases/latest/download/webui.zip";
      #     resourceUrl = "file://${webui}/webui.zip";
      #     urlPrefix = {
      #       "/admin" = true;
      #       "/account" = true;
      #     };
      #   };
      # })
      (destroy "Tracer" {})
      (create "Tracer" [
        (variant "Stdout" {
          level = "info";
          ansi = false;
        })
      ])
      (upsert "Domain" ["name"] {
        ${domRef} = {
          name = domain;
          catchAllAddress = "chad@${domain}";
        };
      })
      (update "SystemSettings" {
        defaultDomainId = id domRef;
        defaultHostname = hostname;
        proxyTrustedNetworks = set ["127.0.0.0/8" "::1"];
      })
      (upsert "Account" ["name"] [
        (variant "User" {
          domainId = id domRef;
          name = "chad";
          roles = variant "Admin" {};
        })
      ])
      # (reconcile "NetworkListener" ["name"] [
      #   { name = "http";        protocol = "http";        bind = set ["${stalwartIp}:10080"]; tlsImplicit = false; }
      #   { name = "sieve";       protocol = "manageSieve"; bind = set ["${stalwartIp}:14190"]; tlsImplicit = false; }
      #   { name = "imaps";       protocol = "imap";        bind = set ["${stalwartIp}:10993"]; tlsImplicit = true;  }
      #   { name = "submissions"; protocol = "smtp";        bind = set ["${stalwartIp}:10465"]; tlsImplicit = true;  }
      #   { name = "smtp";        protocol = "smtp";        bind = set ["${stalwartIp}:10025"]; tlsImplicit = false; }
      # ])
      (reconcile "NetworkListener" ["name"] [
        { name = "http";        protocol = "http";        bind = set ["[::]:10080"]; tlsImplicit = false; }
        { name = "sieve";       protocol = "manageSieve"; bind = set ["[::]:4190"]; tlsImplicit = false; }
        { name = "imaps";       protocol = "imap";        bind = set ["[::]:993"]; tlsImplicit = true;  }
        { name = "submissions"; protocol = "smtp";        bind = set ["[::]:465"]; tlsImplicit = true;  }
        { name = "smtp";        protocol = "smtp";        bind = set ["[::]:25"]; tlsImplicit = false; }
        # ^ stalwart hardcodes port 25 in a lot of checks, I'm too bothered to play duck hunt with that.
        # It should be fixed on their end.
      ])
      (destroy "MemoryLookupKey" { namespace = "spam-traps"; }) # upsert is broken without delete...
      (upsert "MemoryLookupKey" ["namespace" "key"] [
        { namespace = "spam-traps"; key = "trans-migrated@*"; isGlobPattern = true; }
        { namespace = "spam-traps"; key = "info@*";           isGlobPattern = true; }
        { namespace = "spam-traps"; key = "roqwrqworqw@*";    isGlobPattern = true; }
        { namespace = "spam-traps"; key = "u003cchad@*";      isGlobPattern = true; }
      ])
      (upsert "AcmeProvider" ["directory"] {
        ${acmeRef} = {
          directory = "https://acme-v02.api.letsencrypt.org/directory";
          challengeType = "Http01";
          contact = set ["chad@${domain}"];
        };
      })
      (updateId "Domain" (id domRef) {
        certificateManagement = variant "Automatic" {
          acmeProviderId = id acmeRef;
          subjectAlternativeNames = set [hostname];
        };
      })
      (update "SpamClassifier" {
        minHamSamples = 1;
        minSpamSamples = 10;
      })
      (update "ReportSettings" {
        inboundReportForwarding = false;
      })
      (update "DnsResolver" (variant "Cloudflare" {}))
    ];
  };

  networking.firewall.allowedTCPPorts = [
    25
    465
    993
    4190
  ];
}
