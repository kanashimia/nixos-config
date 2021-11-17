{ pkgs, inputs, ... }: {
  nixpkgs.overlays = with inputs; [ xmonad-systemd.overlay ];

  environment.systemPackages = with pkgs; [
    chromium firefox mpc_cli rofi st kotatogram-desktop
  ];

  services.xserver.enable = true;
  services.xserver.windowManager.xmonad = {
    enable = true;
    config = pkgs.substituteAll {
      src = ./xmonad.hs;
      terminal = "st";
    };
    extraPackages = hpkgs: with hpkgs; [
      xmonad-contrib xmonad-systemd
    ];
  };
}
