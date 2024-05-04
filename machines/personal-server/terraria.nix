{ pkgs, config, lib, ... }: let
  terrariaPort = 7777;
  terrariaFifo = "/run/terraria/terraria.sock";
  terrariaConfig = (pkgs.formats.keyValue {}).generate "terraria-config.txt" {
    world = "/var/lib/terraria/worlds/absolutely-new-world.wld";
    worldpath = "/var/lib/terraria/worlds";
    # Creates a new world if none is found. World size is specified by: 1(small), 2(medium), and 3(large).
    autocreate = 3;
    # Sets the world seed when using autocreate
    seed = "05162020";
    # Sets the name of the world when using autocreate
    worldname = "Another time, for another adventure!";
    # Sets the difficulty of the world when using autocreate 0(classic), 1(expert), 2(master), 3(journey)
    difficulty = 2;
    maxplayers = 20;
    port = terrariaPort;
    motd = "Welcome to the absolutely new world! Now with extra content!";
    secure = 0;
    language = "en-US";
    upnp = 0;
    priority = 1;
    npcstream = 1;
  };
in {
  networking.firewall.allowedTCPPorts = [ terrariaPort ];

  nixpkgs.config.allowUnfree = true;

  systemd.sockets.terraria = {
    partOf = [ "terraria.service" ];
    socketConfig = {
      ListenFIFO = terrariaFifo;
      SocketMode = "0660";
      RemoveOnStop = true;
    };
  };

  systemd.services.terraria = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    bindsTo = [ "terraria.socket" ];

    preStop = ''
      [ -p ${terrariaFifo} ] && printf '\nexit\n' > ${terrariaFifo}
    '';

    script = ''
      exec ${lib.getExe pkgs.terraria-server} -config <(
        cat ${terrariaConfig}
        printf '\npassword='
        cat /run/credentials/terraria.service/terrarion
      )
    '';

    serviceConfig = {
      LoadCredentialEncrypted = "terrarion:${./secrets/terrarion.creds}";

      User = "terraria";
      DynamicUser = true;

      RuntimeDirectory = "terraria";
      StateDirectory = "terraria";
      StateDirectoryMode = "0750";

      StandardInput = "socket";
      StandardOutput = "journal";
      StandardError = "journal";

      SyslogIdentifier = "terraria";

      KillSignal = "SIGCONT";
      TimeoutStopSec = "1h";

      # Hardening
      CapabilityBoundingSet = "";
      LockPersonality = true;
      PrivateDevices = true;
      ProcSubset = "pid";
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_NETLINK" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" "~@privileged" ];
      UMask = "0077";
    };
  };
}
