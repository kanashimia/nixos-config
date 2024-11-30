{ config, lib, ... }: {
  systemd.services.systemd-networkd.serviceConfig = {
    LoadCredential = "wg-vpn";
  };

  systemd.network.netdevs."50-wg0" = {
    netdevConfig = {
      Name = "wg0";
      Kind = "wireguard";
    };
    wireguardConfig = {
      PrivateKeyFile = "/run/credentials/systemd-networkd.service/wg-vpn";
      FirewallMark = 34952;
    };
    wireguardPeers = lib.attrValues {
      "personal-server" = {
        PublicKey = "qRHM8s/fgTNWGQDV6l4v53aBrt7sh0mbIQIh7Osz32k=";
        AllowedIPs = [ "0.0.0.0/0" "::/0" ];
        Endpoint = "redpilled.dev:42069";
      };
    };
  };

  systemd.network.networks."50-wg0" = {
    name = "wg0";
    networkConfig = {
      Address = [ "10.0.0.4/32" "fc00:0010::4/128" ];
      Domains = "~.";
    };
    linkConfig = {
      ActivationPolicy = "manual";
    };
    routes = [
      { Table = 1000; Destination = "0.0.0.0/0"; }
      { Table = 1000; Destination = "::/0"; }
    ];
    routingPolicyRules = [{
      Family = "both";
      FirewallMark = 34952;
      InvertRule = true;
      Table = 1000;
      Priority = 10;
    }];
  };

  networking.nftables.tables."wg-wg0" = {
    family = "inet";
    content = ''
      chain preraw {
        type filter hook prerouting priority raw; policy accept;
        iifname != "wg0" ip daddr 10.0.0.4/32 fib saddr type != local drop
        iifname != "wg0" ip6 daddr fc00:0010::4/128 fib saddr type != local drop
      }
      chain premangle {
        type filter hook prerouting priority mangle; policy accept;
        meta l4proto udp meta mark set ct mark
      }
      chain postmangle {
        type filter hook postrouting priority mangle; policy accept;
        meta l4proto udp meta mark 34952 ct mark set meta mark
      }
    '';
  };
}
