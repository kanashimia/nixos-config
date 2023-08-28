{ config, lib, inputs, pkgs, ... }: let
  hostname = "redpilled.dev";
in {
  imports = [ inputs.mailserver.nixosModule ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@${hostname}";

    certs.${hostname} = {
      extraDomainNames = [ "*.${hostname}" ];
      dnsProvider = "cloudflare";
      credentialsFile = "/run/credentials/nginx.service/acme-auth";
      group = config.services.nginx.group;
    };
  };

  systemd.services.nginx.serviceConfig.LoadCredentialEncrypted =
    "acme-auth:${./secrets/acme-auth.creds}";

  services.nginx = {
    enable = true;

    logError = "syslog:server=unix:/dev/log,nohostname";
    appendHttpConfig = ''
      access_log syslog:server=unix:/dev/log,nohostname combined;
    '';

    recommendedProxySettings = true; 
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;

    virtualHosts = let
      def = cfg: cfg // {
        forceSSL = true;
        enableACME = false;
        useACMEHost = hostname;
      };
    in {
      ${hostname} = def {
        locations."/".root = "/srv/www";

        locations."/.well-known/webfinger" = {
          extraConfig = ''
            add_header Access-Control-Allow-Origin '*';
          '';
          return = "301 https://social.${hostname}$request_uri";
        };
      };

      ${config.services.roundcube.hostName} = def {};

      # ${config.services.mastodon.localDomain} = def {};

      "social.${hostname}" = def {
        root = "${config.services.mastodon.package}/public/";

        locations."/system/".alias = "/var/lib/mastodon/public-system/";

        locations."/" = {
          tryFiles = "$uri @proxy";
        };

        locations."@proxy" = {
          proxyPass = "http://unix:/run/mastodon-web/web.socket";
          proxyWebsockets = true;
        };

        locations."/api/v1/streaming/" = {
          proxyPass = "http://unix:/run/mastodon-streaming/streaming.socket";
          proxyWebsockets = true;
        };
      };

      "*.${hostname}" = def {
        globalRedirect = hostname;
      };
    };
  };

  services.rspamd.locals."classifier-bayes.conf".text = ''
    autolearn = true;
  '';

  systemd.services.dovecot2.serviceConfig.LoadCredentialEncrypted =
    "chad-password:${./secrets/chad-password.creds}";

  mailserver = {
    enable = true;
    fqdn = hostname;
    domains = [ hostname ];
    openFirewall = true;

    # A list of all login accounts. To create the password hashes, use
    # nix shell n#apacheHttpd -c htpasswd -nB ""
    loginAccounts = {
      "chad@${hostname}" = {
        hashedPasswordFile = "/run/credentials/dovecot2.service/chad-password";
        aliases = [ "@${hostname}" ];
      };
    };

    certificateScheme = "acme";
  };

  services.roundcube = rec {
    enable = true;
    package = pkgs.roundcube.withPlugins (lib.attrVals plugins);
    hostName = "webmail.${hostname}";
    plugins = [ "persistent_login" ];
    extraConfig = ''
      $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };

  # services.freshrss = {
  #   enable = true;
  #   baseUrl = "rssreader.${hostname}";
  #   virtualHost = "rssreader";
  # };

  systemd.services.mastodon-init-dirs.serviceConfig.LoadCredentialEncrypted =
    "chad-password:${./secrets/chad-password.creds}";

  services.mastodon = {
    enable = true;
    localDomain = hostname;
    enableUnixSocket = true;
    # configureNginx = true;
    smtp = {
      createLocally = false;
      # port = 465;
      # authenticate = true;
      # user = "chad@${hostname}";
      # passwordFile = "/run/credentials/dovecot2.service/chad-password";

      fromAddress = "noreply@${hostname}"; # Email address used by Mastodon to send emails, replace with your own
    };
    extraConfig = {
      SINGLE_USER_MODE = "true";
      WEB_DOMAIN = "social.${hostname}";
    };
  };

  systemd.timers.fedifetcher = {
    enable = false;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "0/2:0";
      Persistent = "yes";
      Unit = "fedifetcher.service";
    };
  };
  systemd.services.fedifetcher = let
    configFile = pkgs.writeText "config.json" (builtins.toJSON {
      server = "social.redpilled.dev";
      home-timeline-length = 200;
      max-followings = 80;
      from-notifications = 1;
    });
  in {
    enable = false;
    after = [ "mastodon-web.service" ];
    requires = [ "mastodon-web.service" ];
    serviceConfig = {
      StateDirectory = "fedifetcher";
      Type = "oneshot";
      LoadCredentialEncrypted = "fedifetcher-access-token:${./secrets/fedifetcher-access-token.creds}";
      ExecStart = "-${pkgs.writeShellScriptBin "fedifetcher" ''
        read -r ACCESS_TOKEN < "$CREDENTIALS_DIRECTORY/fedifetcher-access-token"
        exec ${pkgs.fedifetcher}/bin/fedifetcher \
          --access-token="''${ACCESS_TOKEN}" \
          --state-dir="''${STATE_DIRECTORY}" \
          -c ${configFile}
      ''}/bin/fedifetcher";
      User = "mastodon";
    };
  };

  users.groups.${config.services.mastodon.group}.members = [ config.services.nginx.user ];

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    logRefusedConnections = false;
  };

  systemd.network.networks."40-wired" = {
    name = "en*";
    networkConfig = {
      DHCP = "yes";
      Address = [ "2a01:4f8:1c1c:f8e2::/64" ];
      Gateway = [ "fe80::1" ];
    };
    dhcpV4Config.UseDNS = false;
    dhcpV6Config.UseDNS = false;
  };

  services.journald.extraConfig = ''
    SystemMaxUse=100M
  '';
}
