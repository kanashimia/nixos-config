{
  # Do not show boot loader menu unless explicitly desired.
  # It is still accessible by holding random keys during early boot.
  boot.loader.timeout = 0;

  # Disable systemd-boot editor, as it is an security issue.
  boot.loader.systemd-boot.editor = false;

  # Add nixos as a first EFI entry.
  boot.loader.efi.canTouchEfiVariables = true;
}
