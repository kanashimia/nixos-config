{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vivaldi
  ];

  nixpkgs.config.vivaldi = {
    proprietaryCodecs = true;
    enableWidewine = true;
  };
}
