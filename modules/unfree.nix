{ config, lib, ... }: let
  conf = config.environment.allowUnfreePackages;
in {
  options = {
    environment.allowUnfreePackages = lib.mkOption {
      type = with lib.types; listOf package;
    };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg:
      lib.elem (lib.getName pkg) (map lib.getName conf);
  };
}
