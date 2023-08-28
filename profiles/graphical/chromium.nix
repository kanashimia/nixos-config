{ lib, config, nixosModules, ... }: {
  programs.chromium = {
    enable = true;
    extraOpts = {
      "PasswordManagerEnabled" = false;
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
      #"BrowserThemeColor" = "#111111";
      # "DeviceStartUpFlags" = [ "enable-gpu-rasterization" ];
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # nixpkgs.overlays = [(final: prev: {
  #   chromium = final.symlinkJoin {
  #     name = "chromium";
  #     paths = [ prev.chromium ];
  #     nativeBuildInputs = [ prev.makeWrapper ];
  #     postBuild = let
  #       flags = lib.concatStringsSep " " [
  #         #"--enable-gpu-rasterization"
  #         #"--enable-features=UseOzonePlatform,VaapiVideoDecoder,ScrollableTabStrip:minTabWidth/90"
  #         "--ozone-platform-hint=auto"
  #         # "--use-angle=vulkan"
  #         # "--use-cmd-decoder=passthrough"
  #         # "--force-dark-mode"
  #       ];
  #     in ''
  #       wrapProgram $out/bin/chromium --add-flags '${flags}'
  #     '';
  #   };
  # })];
}
