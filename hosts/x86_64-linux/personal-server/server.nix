{ config, lib, inputs, ... }: let
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
      ${hostname}.locations."/".root = "/srv/www";
      "*.${hostname}".globalRedirect = hostname;
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
}
