{ config, lib, inputs, ... }:

let
  hostname = "redpilled.dev";
  certDir = config.security.acme.certs.${hostname}.directory;
in {
  imports = [ inputs.mailserver.nixosModule ];

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
    recommendedTlsSettings = true;

    virtualHosts = lib.mapAttrs (_: vh: vh // {
      onlySSL = true;
      useACMEHost = hostname;
    }) {
      ${hostname} = {
        locations."/" = {
          root = "/srv/www";
        };
      };
      "rspamd.${hostname}" = {
        locations."/" = {
          proxyPass = "http://unix:/run/rspamd/worker-controller.sock:/";
        };
        basicAuthFile = config.age.secrets.rspamd-password.path;
      };
      "*.${hostname}" = {
        globalRedirect = hostname;
      };
    };
  };

  services.rspamd.locals."classifier-bayes.conf".text = ''
    autolearn = true;
  '';

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
  networking.firewall.logRefusedConnections = false;
}
