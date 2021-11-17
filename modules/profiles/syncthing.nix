{ lib, ... }: {
  services.syncthing = rec {
    enable = true;
    openDefaultPorts = true;

    user = "kanashimia";
    group = "users";
    dataDir = "/home/${user}";

    devices = lib.mapAttrs (k: v: v // { name = k; }) {
      ati-workstation.id = "NQFJH5X-47SUD5O-B5LIUF3-MN5CGLX-IEZMPSD-KFCAB4N-OO22PX6-7NRXGQJ";
      battleworn-phone.id = "XN3GANY-G7LQZU6-D73DSBJ-FCYMRHN-XGO6L3L-R6RJP64-GGNW4TX-VS2EXQF";
      hp-laptop.id = "N67TXW5-WOL2Z2X-26M65XJ-Q2CPXHH-HLXIHC2-L6J3EGI-FRP6PJ5-LATIWQM";
    };

    folders = let
      emptyDefault = { Sync.enable = false; };
      dirs = lib.genAttrs [
        "documents" "pictures" "music" "projects"
      ] (folder: {
        enable = true;
        path = "~/${folder}";
        devices = lib.attrNames devices;
      });
    in emptyDefault // dirs;
  };
}
