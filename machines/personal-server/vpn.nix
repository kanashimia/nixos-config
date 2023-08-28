{ config, lib, ... }: let
  mkWgPeers = lib.mapAttrsToList (k: v: { wireguardPeerConfig = v; });
in {
  systemd.services.systemd-networkd.serviceConfig = {
    LoadCredentialEncrypted = "wg-private:${./secrets/wg-private.creds}";
  };

  systemd.network.netdevs."50-wg0" = {
    netdevConfig = {
      Name = "wg0";
      Kind = "wireguard";
    };
    wireguardConfig = {
      PrivateKeyFile = "/run/credentials/systemd-networkd.service/wg-private";
      ListenPort = 42069;
    };
    wireguardPeers = mkWgPeers {
      "phone" = {
        PublicKey = "mUf5d7oD9VrRRCw5DE6KxB1CKU2D7yKQM0cMkjv1YT0=";
        AllowedIPs = "10.0.0.2/32";
      };
      "tablet" = {
        PublicKey = "Gsc/Ho2hXNLWwGwg5yC9MwtHhA0veBjL908/2I684WA=";
        AllowedIPs = "10.0.0.3/32";
      };
    };
  };

  systemd.network.networks."50-wg0" = {
    name = "wg0";
    networkConfig = {
      Address = "10.0.0.1/24";
      IPMasquerade = "both";
    };
  };

  networking.firewall.allowedUDPPorts = [ 42069 ];
}
