{ config, lib, pkgs, ... }: let
  tsStunPort = 3478;
  tsPort = 8000;
in {
  networking.hosts = {
    "127.0.1.2" = [ "headscale.internal" ];
  };

  networking.firewall.allowedUDPPorts = [ tsStunPort ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # services.knot = {
  #   enable = true;
  #   settings = {
  #     server.listen = [ "0.0.0.0@53" "::@53" ];
  #     zone = [
  #       { domain = " }
  #     ];
  #   };
  # };

  # services.coredns.enable = true;
  # services.coredns.extraArgs = [ "-dns.port=53" ];
  # services.coredns.config = ''
  #   ts.redpilled.dev {
  #     rewrite stop {
  #       name regex (.*)\.ts\.redpilled\.dev {1}.koi-ayu.ts.net
  #       answer auto
  #     }
  #     forward . 100.100.100.100
  #   }
  # '';

  systemd.services.headscale.serviceConfig = {
    LoadCredential = "headscale_policy";
  };

  services.headscale = {
    enable = true;
    address = "headscale.internal";
    port = tsPort;
    settings = {
      dns.base_domain = "ts.redpilled.dev";
      # dns.search_domains = [ "" ];
      dns.nameservers.global = [ "1.1.1.1" "9.9.9.9" "8.8.8.8" ];
      server_url = "https://headscale.redpilled.dev";
      policy.path = "/run/credentials/headscale.service/headscale_policy";
      # log.level = "debug";

      dns.extra_records = [
        # { name = "redpilled.dev"; type = "A"; value = "100.64.0.2"; }
        { name = "mail.redpilled.dev"; type = "A"; value = "100.64.0.2"; }
        # { name = "firebaselogging.googleapis.com"; type = "A"; value = "5.188.118.207"; }
        # { name = "firebaselogging.googleapis.com"; type = "A"; value = "100.64.0.2"; }
        # { name = "ts.local"; type = "A"; value = "100.100.100.100"; }
        # { name = "ts.internal"; type = "A"; value = "100.100.100.100"; }
        # { name = "ts.home.arpa"; type = "A"; value = "100.100.100.100"; }
        # { name = "redpilled.dev"; type = "AAAA"; value = "fd7a:115c:a1e0::2"; }
        # { name = "mail.redpilled.dev"; type = "AAAA"; value = "fd7a:115c:a1e0::2"; }
      ];

      #   mkRoutes = id: domains: 
      #     builtins.concatMap (domain: [
      #       { name = domain; type = "A"; value = "100.64.0.${toString id}"; }
      #       # { name = domain; type = "AAAA"; value = "fd7a:115c:a1e0::${toString id}"; }
      #     ]) domains;
      # in mkRoutes 2 [ "redpilled.dev" "mail.redpilled.dev" ];

      # dns.nameservers.split = {
      #   "redpilled.dev" = [ "100.64.0.2" ];
      #   # 195.201.40.199
      # };

      derp.server = {
        enable = true;
        region_id = 999;
        stun_listen_addr = "0.0.0.0:${toString tsStunPort}";
        # urls = [
        #   # "https://controlplane.tailscale.com/derpmap/default"
        # ];
        # paths = [
        #   (pkgs.writeText "derp.yaml"
        #     (lib.generators.toJSON {} { regions = lib.range 0 40 |> map (x: lib.nameValuePair (toString x) null) |> lib.listToAttrs; })
        #   )
        # ];
      };
    };
  };

  # services.headplane = {
  #   enable = false;
  #   settings = {
  #     server = {
  #       port = 44117;
  #       host = "127.0.0.1";
  #       # cookie_secret_path = config.sops.secrets."headplane/cookie_secret".path;
  #       cookie_secret_path = "/etc/credstore/headplane_cookie_secret";
  #       cookie_secure = false;
  #     };
  #     headscale = {
  #       url = config.services.headscale.settings.server_url;
  #       config_path = let
  #         # A workaround generate a valid Headscale config accepted by Headplane when `config_strict == true`.
  #         settings = lib.recursiveUpdate config.services.headscale.settings {
  #           tls_cert_path = "/dev/null";
  #           tls_key_path = "/dev/null";
  #           policy.path = "/dev/null";
  #         };
  #         format = pkgs.formats.yaml { };
  #         headscaleConfig = format.generate "headscale.yml" settings;
  #       in "${headscaleConfig}";
  #     };
  #     integration.agent = {
  #       enabled = true;
  #       pre_authkey_path = "/etc/credstore/headplane_pre_authkey";
  #       # pre_authkey_path = config.sops.secrets."headplane/preauth_key".path;
  #     };
  #     # oidc = {
  #     #   issuer: 'https://id.redpilled.dev'
  #     #   client_id: '<CLIENT-ID>'
  #     #   client_secret: '<CLIENT-SECRET>'
  #     #   pkce:
  #     #     enabled: true
  #     #     method: S256
  #     # };
  #   };
  # };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
    extraDaemonFlags = [ "--no-logs-no-support" ];

    # authKeyFile = "/etc/credstore/tailscale_authkey";
    # authKeyParameters = {
    #   preauthorized = true;
    #   baseURL = "https://headscale.redpilled.dev";
    # };

    # extraSetFlags = [ "--advertise-exit-node" "--ssh" ];
    # extraUpFlags = [
    #   "--login-server=https://headscale.redpilled.dev"
    #   "--advertise-routes=0.0.0.0/0,::/0"
    #   "--advertise-exit-node"
    #   "--ssh"
    #   "--reset"
    #   "--force-reauth"
    # ];
  };

  # services.networkd-dispatcher = {
  #   enable = true;
  #   rules."50-tailscale" = {
  #     onState = ["routable"];
  #     script = ''
  #       ${lib.getExe pkgs.ethtool} -K enp1s0 rx-udp-gro-forwarding on rx-gro-list off
  #     '';
  #   };
  # };

  systemd.network.links."90-gro-offload" = {
    matchConfig = {
      OriginalName = "enp1s0";
    };
    linkConfig = {
      GenericReceiveOffloadUDPForwarding = true;
      GenericReceiveOffloadList = false;
    };
  };

  systemd.services.tailscaled = {
    serviceConfig = {
      # ProtectSystem = "full";
      ProtectHome = "true";
      PrivateTmp = "disconnected";
      PrivateMounts = "true";
      ProtectKernelTunables = "true";
      ProtectKernelModules = "true";
      ProtectKernelLogs = "true";
      ProtectControlGroups = "true";
      LockPersonality = "true";
      RestrictRealtime = "true";
      ProtectClock = "true";
      MemoryDenyWriteExecute = "true";
      RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK AF_UNIX";
      # CapabilityBoundingSet = "~CAP_BLOCK_SUSPEND CAP_BPF CAP_CHOWN CAP_IPC_LOCK CAP_MKNOD CAP_PERFMON CAP_SYS_BOOT CAP_SYS_CHROOT CAP_SYS_MODULE CAP_SYS_NICE CAP_SYS_PACCT CAP_SYS_PTRACE CAP_SYS_TIME CAP_SYSLOG CAP_WAKE_ALARM";
      # SystemCallFilter = "~@aio:EPERM @chown:EPERM @clock:EPERM @cpu-emulation:EPERM @debug:EPERM @keyring:EPERM @memlock:EPERM @module:EPERM @mount:EPERM @obsolete:EPERM @pkey:EPERM @privileged:EPERM @raw-io:EPERM @reboot:EPERM @resources:EPERM @sandbox:EPERM @setuid:EPERM @swap:EPERM @timer:EPERM"; SystemCallFilter = [ "@system-service" "~@privileged" ];

      SystemCallArchitectures = "native";
      ProtectSystem = "strict";
      NoNewPrivileges = "true";
      ProtectProc = "ptraceable";
      RestrictSUIDSGID = "true";
      RestrictNamespaces = true;
      ProtectHostname = true;
      SystemCallFilter = [ "@system-service" "~@privileged" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_ADMIN" "CAP_NET_RAW" ];
      # IPAddressAllow = [
      #   "100.64.0.0/10" "fd7a:115c:a1e0::/48" 
      #   "100.100.0.0/24" "100.100.100.0/24" "100.115.92.0/23"
      # ];
      # IPAddressDeny = "any";
    };
  };

  # systemd.services.tailscaled.serviceConfig.Environment = [ "TS_DEBUG_MTU=1350" ];

  environment.systemPackages = [ config.services.headscale.package ];

/*
  services.netbird = {
    # enable = true;
    ui.enable = false;
    useRoutingFeatures = "both";
    # interface = "nb0";

    clients.default = {
      port = 41820;
      interface = "nb0";
      name = "netbird";
      hardened = false;
    };

    server = {
      enable = false;
      domain = "nb.redpilled.dev";

      coturn = {
        enable = false;
        password = "netbird";
      };

      management = {
        # port = 10220;
        # metricsPort = 13291;
        enable = false;
        oidcConfigEndpoint = "https://sso.redpilled.dev/.well-known/openid-configuration";
        # turnPort = 13478;
        # turnDomain = "";

        settings = {
          TURNConfig = {
            Turns = [
              {
                Proto = "udp";
                URI = "turn:nb.redpilled.dev:3478";
                Username = "netbird";
                Password = "netbird";
                # Password._secret = "/path/to/a/secret/password";
              }
            ];
          };
          DataStoreEncryptionKey = "genEVP6j/Yp2EeVujm0zgqXrRos29dQkpvX0hHdEUlQ=";
        };

      };
    };
    # https://example.eu.auth0.com/.well-known/openid-configuration

    server.dashboard = {
      enable = false;
      settings = {
        AUTH_OIDC_CONFIGURATION_ENDPOINT = "https://sso.redpilled.dev/.well-known/openid-configuration";
        AUTH_AUTHORITY = false;
        # AUTH_SILENT_REDIRECT_URI= "/silent-auth";
        USE_AUTH0 = false;
        AUTH_DEVICE_AUTH_PROVIDER = "hosted";
        # AUTH_SUPPORTED_SCOPES = "openid profile email offline_access api";
        # AUTH_SUPPORTED_SCOPES="openid profile email groups"


AUTH_CLIENT_ID="5a623684-c47f-4772-ba14-6e31ccb27d5f";
AUTH_SUPPORTED_SCOPES="openid profile email groups";
AUTH_AUDIENCE="5a623684-c47f-4772-ba14-6e31ccb27d5f";
AUTH_REDIRECT_URI="/auth";
AUTH_SILENT_REDIRECT_URI="/silent-auth";
TOKEN_SOURCE="idToken";

NETBIRD_AUTH_DEVICE_AUTH_PROVIDER="none";
NETBIRD_AUTH_DEVICE_AUTH_CLIENT_ID="5a623684-c47f-4772-ba14-6e31ccb27d5f";
NETBIRD_AUTH_DEVICE_AUTH_AUDIENCE="5a623684-c47f-4772-ba14-6e31ccb27d5f";
NETBIRD_AUTH_DEVICE_AUTH_SCOPE="openid profile email groups";
NETBIRD_AUTH_DEVICE_AUTH_USE_ID_TOKEN=true;

NETBIRD_MGMT_IDP="pocketid";
NETBIRD_IDP_MGMT_CLIENT_ID="netbird";
NETBIRD_IDP_MGMT_EXTRA_MANAGEMENT_ENDPOINT="https://sso.redpilled.dev";
NETBIRD_IDP_MGMT_EXTRA_API_TOKEN="YbzKQAmTGoQ7RWU5DPLG58QlRB3e2gjI";
      };
    };

    # reverse_proxy /signalexchange.SignalExchange/* h2c://localhost:${toString config.services.netbird.server.signal.port}
    # reverse_proxy /api/* localhost:${toString config.services.netbird.server.management.port}
    # reverse_proxy /management.ManagementService/* h2c://localhost:${toString config.services.netbird.server.management.port}


    
        # port = 51820;
        # name = "netbird";
        # interface = "wt0";
        # hardened = false;

  };

*/

  services.pocket-id = {
    enable = false;
    # environmentFile = "/etc/credstore/pocketid";
    settings = {
      APP_URL = "https://sso.redpilled.dev";
      HOST = "127.0.0.1";
      METRICS_ENABLED = true;
      PORT = 51022;
      TRUST_PROXY = true;
      UI_CONFIG_DISABLED = true;
    };
  };
}

