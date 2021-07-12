{ lib, config, pkgs, inputs, ... }:

{
  options.profiles.default.enable = lib.mkOption {
    default = true;
    example = false;
    description = "Whether to enable default profile.";
    type = lib.types.bool;
  };

  config = lib.mkIf config.profiles.default.enable {
    # Some default programs that i always use.
    environment.systemPackages = with pkgs; [ gitMinimal kakoune ];

    # Enable flake support for nix, don't warn on dirty repos.
    nix.package = pkgs.nixUnstable;
    nix.extraOptions = ''
      experimental-features = nix-command flakes ca-references
      warn-dirty = false
    '';

    # Use n as an alias to the current configs nixpkgs.
    nix.registry.n.flake = inputs.nixpkgs;

    # Hardlink identical files in nix store.
    nix.autoOptimiseStore = true;

    # Automatically delete old generations.
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    # Do not show boot loader menu unless explicitly desired.
    # It is still accessible by holding random keys during early boot.
    boot.loader.timeout = 0;

    # Disable systemd-boot editor, as it is an security issue.
    # boot.loader.systemd-boot.editor = false;

    # Add nixos as a first EFI entry.
    boot.loader.efi.canTouchEfiVariables = true;

    # Enable zram, a compressed block device in ram, as a swap device.
    zramSwap.enable = true;

    # This is the size of a block device to be created, in a percentage of ram,
    # it doesnt reflect actual memory that is being used in any way.
    # Compression ratio expected to be at least 3x the size of a ram,
    # so having values above 100 is ok.
    zramSwap.memoryPercent = 200;

    # Prioritize swapping to paging
    boot.kernel.sysctl."vm.swappiness" = lib.mkIf config.zramSwap.enable 190;

    # Do not print sometimes helpful, but not always, info during boot,
    # so it is harder to debug system when something goes wrong.
    boot.kernelParams = [ "quiet" ];

    # Layout config.
    services.xserver = {
      xkbOptions = "caps:swapescape,grp:rctrl_rshift_toggle,compose:menu,grp_led:num";
      layout = "us(dvorak),ru,ua";
    };

    # Use same layout for console.
    console.useXkbConfig = true;

    i18n.defaultLocale = "en_IE.UTF-8";
    time.timeZone = "Europe/Kiev";

    users.users.root.password = "root";
    users.mutableUsers = false;
  };
}
