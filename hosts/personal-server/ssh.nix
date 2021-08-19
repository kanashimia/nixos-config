{ pkgs, ... }:

{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;

    authorizedKeysCommand = "/etc/ssh/auth";
  };

  environment.etc."ssh/auth" = {
    mode = "0555";
    text = ''
      #!${pkgs.stdenv.shell}
      ${pkgs.curl}/bin/curl -sf https://github.com/kanashimia.keys
    '';
  };
}
