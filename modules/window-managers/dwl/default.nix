{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [ dwl ];
}
