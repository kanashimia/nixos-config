{ pkgs, config, lib, ... }: {
  services.mia.terraria = {
    enable = false;
    loadCredential = [ "terrarion" ];
    extraConfigPath = "/run/credentials/terraria.service/terrarion";
    settings = {
      world = "/var/lib/terraria/worlds/from-the-new-world.wld";
      worldpath = "/var/lib/terraria/worlds";
      # Creates a new world if none is found. World size is specified by: 1(small), 2(medium), and 3(large).
      autocreate = 3;
      # Sets the world seed when using autocreate
      seed = "05162020";
      # Sets the name of the world when using autocreate
      worldname = "New World";
      # Sets the difficulty of the world when using autocreate 0(classic), 1(expert), 2(master), 3(journey)
      difficulty = 2;
      maxplayers = 20;
      port = 7777;
      motd = "Not all shall last, for what all shall be in the past.";
      secure = 0;
      language = "en-US";
      upnp = 0;
      priority = 1;
      npcstream = 1;
    };
  };

  nixpkgs.config.allowUnfree = true;

  networking.firewall.allowedTCPPorts = [ 7777 ];
}
