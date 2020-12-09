{ pkgs, ...}:

{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userEmail = "nikita20001116@gmail.com";
    userName = "Nikita Ursol";
    extraConfig = {
      credential.helper = "libsecret";
    };
  };
  services.gnome-keyring.enable = true;
}
