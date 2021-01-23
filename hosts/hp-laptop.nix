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

  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable proprietary non-free garbage.
  hardware.enableRedistributableFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;

  # Enable SysRq key for unexpected situations.
  boot.kernel.sysctl."kernel.sysrq" = 1;

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
  #
  # Wait it works again? Like wth.
  # Also yes, it is indeed a problem with their DSDT
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
  # boot.kernelParams = [ "snd_hda_intel.model=hp-mute-led-mic3" ];
  boot.initrd.kernelModules = [ "kvm-intel" ];
  #boot.blacklistedKernelModules = [ ];
  #boot.extraModulePackages = [ ];
  
  # Networking configuration.
  networking.networkmanager.enable = true;
  networking.hostName = "hp-laptop";
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;

  # Drives.
  fileSystems."/".label = "nixos";
  fileSystems."/boot".label = "boot";

  # Swap drive.
  swapDevices = [{ label = "swap"; }];

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

  # Laptop powersaving, or something.
  services.tlp.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # Steam related fixes.
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  hardware.brillo.enable = true;
}  
