{ pkgs, ... }: {
  # Configuration of the xdg user dirs to create,.
  # As you may see i've added PROJECTS dir,
  # and made so all dirs are in lowercase.
  environment.etc."xdg/user-dirs.defaults".text = ''
    DOCUMENTS=documents
    DOWNLOAD=downloads
    MUSIC=music
    PICTURES=pictures
    PROJECTS=projects
    TEMPLATES=templates
  '';

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update &
  '';
}
