{ lib, ... }: {
  programs.chromium = {
    enable = true;
    extraOpts = {
      "PasswordManagerEnabled" = false;
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
      "BrowserThemeColor" = "#eaeaea";
      "DeviceStartUpFlags" = [ "enable-gpu-rasterization" ];
    };
  };

  nixpkgs.overlays = [(final: prev: {
    chromium = final.symlinkJoin {
      name = "chromium";
      paths = [ prev.chromium ];
      nativeBuildInputs = [ prev.makeWrapper ];
      postBuild = let
        flags = lib.concatStringsSep " " [
          "--enable-gpu-rasterization"
          "--enable-features=UseOzonePlatform,VaapiVideoDecoder,ScrollableTabStrip:minTabWidth/90"
          "--ozone-platform=\${XDG_SESSION_TYPE:-x11}"
        ];
      in ''
        wrapProgram $out/bin/chromium --add-flags '${flags}'
      '';
    };
  })];
}
