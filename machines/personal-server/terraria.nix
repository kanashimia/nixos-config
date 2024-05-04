{ pkgs, config, lib, ... }: let
  terraria-port = 7777;
  terraria-config = (pkgs.formats.keyValue {}).generate "terraria-config.txt" {
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
    port = terraria-port;
    password = "bunker";
    motd = "Welcome to the absolutely new world! Now with extra content!";
    secure = 0;
    language = "en-US";
    upnp = 0;
    priority = 1;
    npcstream = 1;
  };
in {
  networking.firewall = {
    allowedTCPPorts = [ terraria-port ];
    allowedUDPPorts = [ terraria-port ];
  };

  nixpkgs.config.allowUnfree = true;

  users.users.terraria = {
    group = "terraria";
    home = "/var/lib/terraria";
    uid = config.ids.uids.terraria;
  };

  users.groups.terraria = {
    gid = config.ids.gids.terraria;
  };

  systemd.sockets.terraria = {
    partOf = [ "terraria.service" ];
    socketConfig = {
     ListenFIFO = [ "/run/terraria.sock" ];
     SocketUser = "terraria";
     SocketMode = "0660";
     RemoveOnStop = true;
    };
  };

  systemd.services.terraria = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    bindsTo = [ "terraria.socket" ];

    preStop = ''
      printf '\nexit\n' > /run/terraria.sock
    '';

    serviceConfig = {
     User = "terraria";
     ExecStart = "${lib.getExe pkgs.terraria-server} -config ${terraria-config}";

     StateDirectory = "terraria";
     StateDirectoryMode = "0750";

     StandardInput = "socket";
     StandardOutput = "journal";
     StandardError = "journal";

     KillSignal = "SIGCONT";
     TimeoutStopSec = "1h";
    };
  };
}
