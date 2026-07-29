{ pkgs, ... }: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PerSourceNetBlockSize = "24:64";
      # PerSourcePenalties = "crash:90s authfail:5s noauth:1s grace-exceeded:20s max:10m min:15s";
      # PerSourcePenalties = "crash:1h authfail:5m noauth:5m grace-exceeded:1m min:15s max:24h";
    };
    ports = [4713];
  };
  # services.fail2ban.enable = false;
}
