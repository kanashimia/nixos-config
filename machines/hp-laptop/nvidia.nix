{ pkgs, lib, config, inputs, ... }: let
proprietary-cfg = {
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  systemd.services.greetd.unitConfig = {
    Wants = [ "dev-dri-nvidia.device" ];
    After = [ "dev-dri-nvidia.device" ];
  };

  hardware.nvidia.nvidiaSettings = false;

  # hardware.nvidia.prime = {
  #   offload.enable = true;
  #   intelBusId = "PCI:0:1:0";
  #   nvidiaBusId = "PCI:1:0:0";
  # };

  boot.extraModprobeConfig = ''
    options nvidia-drm modeset=1
  '';

  # systemd.services.nvidia-poweroff = rec {
  #   enable = true;
  #   description = "Unload nvidia modules from kernel";
  #   documentation = [ "man:modprobe(8)" ];
  #
  #   unitConfig.DefaultDependencies = "no";
  #
  #   after = [ "umount.target" ];
  #   before = wantedBy;
  #   wantedBy = [ "shutdown.target" "final.target" ];
  #
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "-${pkgs.kmod}/bin/rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia";
  #   };
  # };
};
in {
  imports = [ proprietary-cfg ];

  programs.sway.extraOptions = [
    "--unsupported-gpu"
    "-Dnoscanout"
  ];

  environment.systemPackages = with pkgs; [ nvtop ];

  environment.sessionVariables = {
    WLR_RENDERER = "vulkan";

    # WLR_DRM_DEVICES = "/dev/dri/intel";
    # WLR_DRM_NO_ATOMIC = "1";

    # WLR_NO_HARDWARE_CURSORS = "1";
    
    # WLR_DRM_NO_MODIFIERS = "1";
    # WLR_EGL_NO_MODIFIERS = "1";
    
    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    
    # WLR_BACKENDS = "drm,libinput";
    # VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
  };
}
