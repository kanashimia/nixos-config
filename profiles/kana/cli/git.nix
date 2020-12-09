{ pkgs, ...}:

{
  # home.sessionVariables
  programs.git = {
    enable = true;
    userEmail = "nikita20001116@gmail.com";
    userName = "Nikita Ursol";
    extraConfig = {
      credential.helper = "cache --timeout=3600";
    };
  };
}
