{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ tdesktop ];

  environment.sessionVariables = {
    TDESKTOP_USE_GTK_FILE_DIALOG = "true";
  };
}
