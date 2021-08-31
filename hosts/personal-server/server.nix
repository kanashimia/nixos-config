{ config, pkgs, ... }:

let
  hostname = "redpilled.dev";
  certDir = config.security.acme.certs.${hostname}.directory;
in {
  security.acme.acceptTerms = true;
  security.acme.email = "acme@${hostname}";

  security.acme.certs.${hostname} = {
    extraDomainNames = [ "*.${hostname}" ];
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.acme-auth.path;
    group = config.services.nginx.group;
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
          root = "/srv/www";
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
    fqdn = hostname;
    domains = [ hostname ];

    # A list of all login accounts. To create the password hashes, use
    # nix shell n#apacheHttpd -c htpasswd -nB ""
    loginAccounts = {
      "chad@${hostname}" = {
        hashedPasswordFile = config.age.secrets.chad-password.path;
        aliases = [ "@${hostname}" ];
      };
    };

    certificateScheme = 1;
    certificateFile = "${certDir}/cert.pem";
    keyFile = "${certDir}/key.pem";
  };

  networking.firewall.allowedTCPPorts = [ 443 ];
}
