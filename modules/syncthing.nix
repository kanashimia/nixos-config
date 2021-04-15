{ pkgs, ... }:

{
  home-manager.users.kanashimia = {
    services.syncthing.enable = true;
  };
}
