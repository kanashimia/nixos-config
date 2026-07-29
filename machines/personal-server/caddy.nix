{ config, lib, inputs, pkgs, ... }: {
  networking.hosts = {
    "127.0.1.3" = [ "caddy.internal" ];
  };

  services.caddy = {
    enable = true;
    # package = pkgs.caddy.withPlugins {
    #   plugins = [
    #     # "github.com/mholt/caddy-l4@3c6cc2c0ee0875899fde271fbdef95be3fef7a92"
    #     "github.com/caddy-dns/cloudflare@v0.2.2-0.20250506153119-35fb8474f57d"
    #   ];
    #   hash = "sha256-akdlJZCNpJ0+faYfLWKjVGlfdCqGxE0D3W4170a26Kg=";
    #   # caddyRev = "eaaa2e5872ef9e845a50c6aade36676c0ecfe2e2";
    #   # vendorHash = "sha256-krnqpb10TeGsYLD1p7u9EuP2EfCQjw0PZhky7fPRylY=";
    # };
    configFile = ./Caddyfile;
  };

  environment.systemPackages = [ config.services.caddy.package ];

  # systemd.services.caddy.serviceConfig.Type = "exec";
  # systemd.services.caddy.serviceConfig.ExecStart = let
  #   script = pkgs.writeShellScriptBin "caddy-start" ''
  #     set -e
  #     ${config.services.caddy.package}/bin/caddy run --config /etc/caddy/caddy_config --adapter caddyfile 2>&1 \
  #       | ${pkgs.jq}/bin/jq '"<\({error:3,warn:4,info:6,debug:7}[.level]//4)>\(if .logger then "[\(.logger)] " else "" end)\(.msg) \(del(.msg,.level,.ts,.logger) | if . == {} then "" end)"' -r --unbuffered \
  #       | systemd-cat --level-prefix=true -t caddy
  #   '';
  # in lib.mkForce [ "" "${script}/bin/caddy-start" ];

  # Hack to place data in /var/lib/caddy instead of /var/lib/caddy/.local/share/caddy
  systemd.services."caddy".environment = {
    XDG_DATA_HOME = "/var/lib";
    XDG_CONFIG_HOME = "/var/lib";
  };

  systemd.services."caddy".serviceConfig = {
    LoadCredential = "cool-secret";
  };

  networking.firewall.allowedTCPPorts = [
    80 # http
    443 # https
  ];
  networking.firewall.allowedUDPPorts = [
    443 # https quic
  ];
}
