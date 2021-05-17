{ pkgs, ...}:

let
dwlPackage = pkgs.dwl.override {
  conf = ./config.h;
};
in
{
  environment.systemPackages = with pkgs; [ foot dwlPackage river ];
  # services.xserver.displayManager.sessionPackages = [ dwlPackage ];
  programs.xwayland.enable = true;
  hardware.opengl.enable = true;
}
