{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox nyxt qutebrowser socat
  ];
  home-manager.users.kanashimia = {
    programs.chromium = {
      enable = true;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
      ];
    };
  };
}
