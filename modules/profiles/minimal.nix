{ nixosModules, ... }: {
  imports = with nixosModules; [
    profiles.basic
  ];

  documentation = {
    enable = false;
    nixos.enable = false;
  };

  security.sudo.enable = false;
  #environment.noXlibs = true;
}
