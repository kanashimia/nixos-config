{
  description = "Configuration of my nixos machines.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";

    mailserver.url = "path:/home/kanashimia/projects/nixos-mailserver"; # "gitlab:simple-nixos-mailserver/nixos-mailserver";
    xmonad-systemd.url = "github:kanashimia/xmonad-systemd";

    digimend.url = "github:kurikaesu/digimend-kernel-drivers/xppen-artist22r-pro";
    digimend.flake = false;
  };
  
  outputs = inputs:  let
    inherit (inputs.nixpkgs) lib;
    nlib = import ./lib.nix { inherit lib inputs; };
  in {
    nixosModules = nlib.mkAttrsTree ./modules // {
      ssh-keys = {
        users.users.root.openssh.authorizedKeys.keys =
          lib.attrValues (lib.importTOML ./.agenix.toml).identities;
      };
    };
    overlays = nlib.mkOverlayTree ./overlays;
    nixosConfigurations = nlib.mkNixosConfigs ./hosts;
  };
}
