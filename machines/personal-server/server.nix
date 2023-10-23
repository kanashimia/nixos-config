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
      };

      ${config.services.roundcube.hostName} = def {};

      "*.${hostname}" = def {
        globalRedirect = hostname;
      };
    };
  };

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
        "sieveScript" = ''
          require ["variables", "fileinto", "envelope", "subaddress", "mailbox"];
          if address :localpart :matches ["to", "cc", "bcc"] ["github", "uni"] {
            set :lower :upperfirst "name" "''${0}";
            fileinto :create "INBOX.''${name}";
          }
        '';
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
