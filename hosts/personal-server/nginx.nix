{
  security.acme.acceptTerms = true;
  security.acme.email = "based+acme@redpilled.dev";

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "redpilled.dev" = {
        forceSSL = true;
        enableACME = true;
        # All serverAliases will be added as extra domain names on the certificate.
        serverAliases = [ "www.redpilled.dev" ];
        locations."/" = {
          root = "/var/www";
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
