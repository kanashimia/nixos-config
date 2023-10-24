{ pkgs, lib, config, inputs, ... }: let
proprietary-cfg = {
  services.xserver.videoDrivers = [ "nvidia" ];

  # systemd.services.greetd.unitConfig = {
  #   Wants = [ "dev-dri-nvidia.device" ];
  #   After = [ "dev-dri-nvidia.device" ];
  # };

  hardware.nvidia = {
    nvidiaSettings = false;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = { 
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  services.udev.extraRules = ''
    KERNEL=="nvidia", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidiactl c 195 255'"
    KERNEL=="nvidia", RUN+="${pkgs.runtimeShell} -c 'for i in $$(cat /proc/driver/nvidia/gpus/*/information | grep Minor | cut -d \  -f 4); do mknod -m 666 /dev/nvidia$${i} c 195 $${i}; done'"
    KERNEL=="nvidia_modeset", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-modeset c 195 254'"
    KERNEL=="nvidia_uvm", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-uvm c $$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
    KERNEL=="nvidia_uvm", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-uvm-tools c $$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 1'"
  '';

  boot.extraModprobeConfig = ''
    options nvidia-drm modeset=1
    options nvidia-drm fbdev=1
  '';

   systemd.services.nvidia-poweroff = rec {
     enable = true;
     description = "Unload nvidia modules from kernel";
     documentation = [ "man:modprobe(8)" ];
  
     unitConfig.DefaultDependencies = "no";
  
     after = [ "umount.target" ];
     before = wantedBy;
     wantedBy = [ "shutdown.target" "final.target" ];
  
     serviceConfig = {
       Type = "oneshot";
       ExecStart = "-${pkgs.kmod}/bin/rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia";
     };
   };
};
in {
  imports = [ proprietary-cfg ];

  programs.sway.extraOptions = [ "--unsupported-gpu" ];

  environment.systemPackages = with pkgs; [ nvtop ];

  environment.sessionVariables = {
    WLR_RENDERER = "vulkan";

    # WLR_DRM_DEVICES = "/dev/dri/intel";
    # WLR_DRM_NO_ATOMIC = "1";

    # WLR_NO_HARDWARE_CURSORS = "1";
    
    # WLR_DRM_NO_MODIFIERS = "1";
    # WLR_EGL_NO_MODIFIERS = "1";
    
    # GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
