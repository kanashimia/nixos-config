{ pkgs, lib, config, inputs, ... }: let
nvidia_legacy_580_vulkan_beta = config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs (old: rec {
  version = "580.94.18";
  
  src = pkgs.fetchurl {
    url = "https://developer.nvidia.com/downloads/vulkan-beta-${lib.concatStrings (lib.splitVersion version)}-linux";
    sha256 = "sha256-FcbmHcwyrUt+1k31UgmX2WZNLLJ4BB5L3pbYUMrwtYo=";
  };
});
proprietary-cfg = {
  services.xserver.videoDrivers = [ "nvidia" ];

  # boot.extraModulePackages = [ config.boot.kernelPackages.nvidiaPackages.legacy_580 ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    # package = nvidia_legacy_580_vulkan_beta;
    open = false;
    nvidiaSettings = false;
    powerManagement = {
      enable = true;
      # enable = false;
      # finegrained = true;
    };
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  boot.extraModprobeConfig = ''
    options nvidia-drm modeset=1
  '';
  # options nvidia-drm fbdev=1

  # boot.kernelParams = [
  #   "module_blacklist=simpledrm"
  #   "initcall_blacklist=simpledrm_platform_driver_init"
  #   "i915.fastboot=1"
  # ];

  # boot.initrd.kernelModules = [
  #   "i915" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"
  # ];

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

  environment.systemPackages = with pkgs; [ nvtop mangohud ];

  environment.sessionVariables = {
    # WLR_RENDER_NO_EXPLICIT_SYNC = "1";
    # WLR_RENDERER = "vulkan";
    ANV_DEBUG = "video-decode,video-encode";

    # WLR_DRM_DEVICES = "/dev/dri/intel";
    # WLR_DRM_NO_ATOMIC = "1";

    # WLR_NO_HARDWARE_CURSORS = "1";

    # WLR_DRM_NO_MODIFIERS = "1";
    # WLR_EGL_NO_MODIFIERS = "1";

    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
