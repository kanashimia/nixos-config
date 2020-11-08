{ pkgs, lib, modulesPath, ... }:

{
  imports = [ ../kana.nix ];

  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod"
  ];
  
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };
  boot.consoleLogLevel = 3;

  hardware.enableRedistributableFirmware = true;

  systemd.services.fuck-hp = {
    enable = true;
    description = "Fuck HP";
    script = ". /dev/input/js0";
    wantedBy = [ "default.target" ];
  };

  services.logind = {
    extraConfig = "HandlePowerKey=hibernate";
    lidSwitch = "suspend-then-hibernate";
  };
  
  boot.kernelParams = [ "quiet" ];

  boot.initrd.kernelModules = [ "kvm-intel" ];
  boot.blacklistedKernelModules = [ ];
  boot.extraModulePackages = [ ];
  
  networking.networkmanager.enable = true;
  networking.hostName = "hp-laptop";
  networking.networkmanager.wifi.backend = "iwd";

  # Disabling this speeds up startup dramatically as it seems.
  # I don't care, lamao.
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

  # Is this reverse prime?? Why do i have to do this? It worked on arch -_-
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0
  '';

  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  environment.systemPackages = with pkgs; [(
    pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec -a "$0" "$@"
    ''
  )];

  # Laptop powersaving, or something.
  services.tlp.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}  
