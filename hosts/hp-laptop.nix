{ pkgs, lib, modulesPath, ... }:

{
  imports = [ ../kana.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };
  boot.consoleLogLevel = 3;

  hardware.enableRedistributableFirmware = true;

  systemd.services.fuck-hp = {
    description = "Fuck HP";
    script = ". /dev/input/js0";
    wantedBy = [ "default.target" ];
  };

  systemd.services.fuck-hp.enable = true;

  services.logind.lidSwitch = "ignore";
  
  # boot.kernelParams = [ "acpi_osi=!" "acpi_osi='Windows 2017'" "acpi_backlight=native" ];
  boot.kernelParams = [
    # "acpi_osi=!"
    # "acpi_osi=Linux"
    "quiet"
    # "video.use_bios_initial_backlight=0"
    # "acpi_backlight=vendor"
    # "acpi_osi="
    # "acpi_backlight=native"
    # "acpi=off"
    # "video.use_native_backlight=1"
  ];
  # boot.consoleLogLevel = 3;
  #
  # hardware.enableAllFirmware = true;
  boot.initrd.kernelModules = [ "kvm-intel" ];
  # boot.blacklistedKernelModules = [
  #   "nouveau"
  #   "rivafb"
  #   "nvidiafb"
  #   "rivatv"
  #   "nv"
  #   "uvcvideo"
  # ];
  boot.extraModulePackages = [ ];
  
  networking.networkmanager.enable = true;
  networking.hostName = "hp-laptop";
  networking.networkmanager.wifi.backend = "iwd";
  # systemd.services.NetworkManager-wait-online.enable = false;
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/boot"; };

  swapDevices = [{
    device = "/dev/disk/by-label/swap";
    priority = 10;
    size = null;
  }];

  services.xserver.videoDrivers = [ "nvidia" ];

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0
    ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-1-0 --auto --primary
  '';

  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime = {
    offload.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };


  environment.systemPackages = let nvidia-offload =
    pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec -a "$0" "$@"
    '';
  in with pkgs; [ nvidia-offload ];
  
  services.tlp.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}  
