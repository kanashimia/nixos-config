{ options, inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ gitMinimal kakoune ];
  nix.package = pkgs.nixFlakes;
  #fonts.fontconfig.enable = false;
  ## console.packages = options.console.packages.default ++ [ pkgs.terminus_font ];
  #users.users.root.initialHashedPassword = "";
  #security.sudo.enable = false;
  #services.getty.autologinUser = "root";
  #services.openssh = {
  #  enable = true;
  #  permitRootLogin = "yes";
  #};
  #environment.variables.GC_INITIAL_HEAP_SIZE = "1M";
  #boot.kernel.sysctl."vm.overcommit_memory" = "1";
  #networking.firewall.logRefusedConnections = false;
  #documentation.enable = mkDefault false;
  #documentation.nixos.enable = false;
  #environment.noXlibs = true;
}
