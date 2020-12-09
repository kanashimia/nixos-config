{ pkgs, lib, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod"
  ];
  
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };
  boot.consoleLogLevel = 3;

  # Enable proprietary non-free garbage.
  hardware.enableRedistributableFirmware = true;

  # Please, please never buy HP laptops,
  # especially if you are going to be using linux,
  # everything about their firmware makes me wanna cry.
  # Like why do my "function" keys don't function
  # unless i load device by hands, and, AND,
  # even then that device is there only half of the time,
  # and, if it isn't there (because probably it isn't),
  # you have to do a hard shutdown to make it appear.
  # Idk how to feel about this, sounds like a sitcom.
  #
  # Edit: Ah fuck, even this doesen't work anymore.
  # I'll keep it for historical reference.
  systemd.services.fuck-hp = {
    enable = false;
    description = "Fuck HP";
    script = ". /dev/input/js0";
    wantedBy = [ "default.target" ];
  };

  services.logind = {
    extraConfig = "HandlePowerKey=hibernate";
    lidSwitch = "ignore"; # "suspend-then-hibernate";
  };
  
  # Boot params and stuff.
  boot.kernelParams = [ "quiet" ];
  boot.initrd.kernelModules = [ "kvm-intel" ];
  boot.blacklistedKernelModules = [ ];
  boot.extraModulePackages = [ ];
  
  # Networking configuration.
  networking.networkmanager.enable = true;
  networking.hostName = "hp-laptop";
  networking.networkmanager.wifi.backend = "iwd";
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/boot"; };

  swapDevices = [{
    device = "/dev/disk/by-label/swap";
    priority = 10;
    size = null;
  }];

  # Oh no.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Finally, nvidia doesen't (completely) suck.
  # prime.sync works so much better than prime.offload
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime = {
    sync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  
  # Fix xorg tearing meme.
  services.xserver.screenSection = ''
    Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
  '';

  services.autorandr.enable = true;

  environment.systemPackages = with pkgs; [
    ( pkgs.writeShellScriptBin "screen-toggle" ''
        MONITORS=$(xrandr --listactivemonitors | wc -l)
        STATE=$(test $MONITORS -gt 2 && echo '--off' || echo '--auto')
        xrandr --output eDP-1-1 $STATE
      ''
    )
  ];

  # Laptop powersaving, or something.
  services.tlp.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # Steam related fixes.
  hardware.opengl = {
    driSupport32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };
  hardware.pulseaudio.support32Bit = true;
}  
