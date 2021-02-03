{ pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "kvm_intel"
  ];

  # Enable systemd boot, because it is superior.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.editor = false;
    timeout = 0;
  };

  # Bleeding edge ha, ha.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Remove some noise from the boot.
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" ];

  # Enable proprietary non-free garbage.
  hardware.enableRedistributableFirmware = true;

  # Use updated microcode because hardware bugs are fun.
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
  # Wait it works again? Like wth. And now it doesen't, ok.
  # Also yes, it is indeed a problem with their DSDT.
  systemd.services.fuck-hp = {
    enable = false;
    description = "Fuck HP";
    script = ". /dev/input/js0";
    wantedBy = [ "default.target" ];
  };

  services.logind = {
    extraConfig = "HandlePowerKey=hibernate";
    lidSwitch = "ignore";
  };
  
  # Networking configuration.
  networking.hostName = "hp-laptop";

  networking.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = true;
  
  # iwd + systemd-networkd > NetworkManager.
  networking.useNetworkd = true;
  networking.wireless.iwd.enable = true;

  # Disable udev-settle hack, see #107382 on nixpkgs.
  systemd.services.systemd-udev-settle.enable = false;

  # Drives.
  fileSystems."/".label = "nixos";
  fileSystems."/boot".label = "boot";

  # Swap drive.
  # swapDevices = [{
  #   label = "swap";
  # }];

  # In-memory swap.
  zramSwap.enable = true;

  # Oh no.
  services.xserver.videoDrivers = [ "nvidia" ];
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
  powerManagement.cpuFreqGovernor = "powersave";

  # Steam related fixes.
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  # Program to control backlight.
  hardware.brillo.enable = true;
}  
