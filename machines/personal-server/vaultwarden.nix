{
  # environment.etc."systemd/dnssd/vaultwarden.dnssd".text = ''
  #   [Service]
  #   Name=vaultwarden
  #   Type=_http._tcp
  #   Port=8000
  # '';

  # vaultwarden._http._tcp.local

  networking.hosts = {
    "127.0.1.1" = [ "vaultwarden.internal" ];
  };
  services.vaultwarden = {
    enable = true;
    # environmentFile = "/run/credentials/vaultwarden.service/vaultwarden";
    # backupDir = "/srv/vaultwarden-backup";
    config = {
      DOMAIN = "https://vault.redpilled.dev";
      SIGNUPS_ALLOWED = false;
      ROCKET_PORT = "8000";
      ROCKET_ADDRESS = "127.0.1.1";
      WEBSOCKET_ENABLED = true;
      # ROCKET_ADDRESS = "localhost";
      # SMTP_FROM = "vault@redpilled.dev";
      SMTP_HOST = "mail.redpilled.dev";
      HELO_NAME = "mail.redpilled.dev";
      # hopefully no one is eavedropping on localhost lol
      # SMTP_SECURITY = "off";
      LOG_LEVEL = "warn";
      USE_SYSLOG = true;
      EXTENDED_LOGGING = false;
      SHOW_PASSWORD_HINT = false;
    };
  };

  systemd.services."vaultwarden" = {
    serviceConfig = {
      LoadCredential = "vaultwarden";
    };
    environment = {
      ENV_FILE = "%d/vaultwarden";
    };
  };
}
