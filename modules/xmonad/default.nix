{ pkgs, config, ... }:

let
haskellPackages-overlay = self: super: {
  haskellPackages = super.haskellPackages.override {
    overrides = hself: hsuper: {
      xmonad = let
        src = super.fetchFromGitHub {
          owner = "xmonad";
          repo = "xmonad";
          rev = "4a0b166998a838d91f002991da82507a2d04d3bb";
          sha256 = "uJClI5qg8N5F02Z1vjhPDjr5t4S9Xx25DQDwo0jsSu4=";
        };
      in hsuper.callCabal2nix "xmonad" src {};

      xmonad-contrib = let
        src = super.fetchFromGitHub {
          owner = "xmonad";
          repo = "xmonad-contrib";
          rev = "8f331d44f11dca21a5dae3fb9e95051938f15f50";
          sha256 = "HeJXGA8c3AgYKaOexPCb+6l/a9ZgHOkd2nZsHm5eig4=";
        };
      in hsuper.callCabal2nix "xmonad-contrib" src {};
    };
  };
};
in
{
  #nixpkgs.overlays = [ haskellPackages-overlay ];
  services.xserver.enable = true;

  services.dbus.packages = with pkgs; [ flameshot ];
  environment.systemPackages = with pkgs; [ firefox alacritty rofi ];

  services.xserver.windowManager.xmonad = {
    enable = true;

    config = with pkgs; substituteAll {
      src = ./xmonad.hs;

      browser = "${firefox}/bin/firefox";
      terminal = "${alacritty}/bin/alacritty";
      chat = "${tdesktop}/bin/telegram-desktop";
      mail = "${thunderbird}/bin/thunderbird";
      search = "${rofi}/bin/rofi -show drun -show-icons -m -4";
      screenshot = "${flameshot}/bin/flameshot gui";
      virtualised = config.services.qemuGuest.enable;
    };

    enableContribAndExtras = true;
    #extraPackages = hpkgs: with hpkgs; [ xmonad-contrib ];
  };
}
