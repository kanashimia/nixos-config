{ lib, ... }:

{
  services.syncthing = rec {
    enable = true;
    openDefaultPorts = true;

    user = "kanashimia";
    group = "users";

    configDir = "/home/${user}/.config/syncthing";
    dataDir = "/home/${user}/.local/share/syncthing";

    declarative.overrideDevices = false;

    declarative.folders = let
      dirs = lib.genAttrs [ "Documents" "Pictures" "Music" ] opts;
      opts = folder: {
        enable = true;
        path = "~/${folder}";
      };
    in { Sync.enable = false; } // dirs;
  };
}
