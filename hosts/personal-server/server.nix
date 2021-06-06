{ config, pkgs, ... }:

let
hostname = "redpilled.dev";
certDir = config.security.acme.certs.${hostname}.directory;
in
{
  security.acme.acceptTerms = true;
  security.acme.email = "acme@${hostname}";

  security.acme.certs.${hostname} = {
    extraDomainNames = [ "*.${hostname}" ];
    dnsProvider = "vultr";
    credentialsFile = "/run/secrets/redpilled-cert";
    group = "nginx";
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      ${hostname} = {
        onlySSL = true;
        useACMEHost = hostname;
        locations."/" = {
          root = "/var/www";
        };
      };
      "*.${hostname}" = {
        onlySSL = true;
        useACMEHost = hostname;
        globalRedirect = hostname;
      };
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.${hostname}";
    domains = [ hostname ];

    # A list of all login accounts. To create the password hashes, use
    # nix run n#apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
    loginAccounts = {
      "chad@${hostname}" = {
        hashedPasswordFile = "/run/secrets/redpilled-mail";
        aliases = [ "@${hostname}" ];
      };
    };

    certificateScheme = 1;
    certificateFile = "${certDir}/cert.pem";
    keyFile = "${certDir}/key.pem";
  };

  networking.firewall.allowedTCPPorts = [ 443 ];
}
