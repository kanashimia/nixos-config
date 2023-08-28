{ nixosModules, pkgs, lib, config, ... }: {
  imports = with nixosModules; [
    ../basic
    ./chromium.nix
    ./foot
    ./steam
    ./sway
    ./themes/colors.nix
    ./themes/gtk.nix
  ];

  users.users.kanashimia = {
    uid = 1000;
    description = "Kanashimia";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "kanashimia";
  };

  programs.git.enable = true;
  programs.git.config = {
    init.defaultBranch = "mistress";
    user = {
        signingKey = "~/.ssh/id_ed25519.pub";
        email = "chad@redpilled.dev";
        name = "Mia Kanashi";
    };
    commit.gpgsign = true;
    gpg = {
       format = "ssh";
    };
  };

  environment.systemPackages = with pkgs; [
    mypaint krita
    
    ripgrep fd sd tree dua nix-tree du-dust
    pciutils usbutils htop-vim hydra-check
    strace ltrace hyperfine
    fwts lshw cpuid evtest nvme-cli hwinfo
    jq swaycwd watchexec file xdg-utils
    lsof chafa lf hdparm
    unar
    dmidecode smartmontools
    iw
    config.boot.kernelPackages.perf
    libinput

    ardour
    qpwgraph
    musescore

    liquidsfz
    sfizz
    distrho
  ];

  environment.variables = {
    LADSPA_PATH = "/run/current-system/sw/lib/ladspa"; # lib.makeSearchPath "lib/ladspa" plugins;
    LV2_PATH    = "/run/current-system/sw/lib/lv2"; # lib.makeSearchPath "lib/lv2" plugins;
    VST_PATH    = "/run/current-system/sw/lib/vst"; # lib.makeSearchPath "lib/vst" plugins;
    VST3_PATH   = "/run/current-system/sw/lib/vst3"; # lib.makeSearchPath "lib/vst3" plugins;
  };

  services.udev.extraHwdb = ''
    evdev:input:b0003v28BDp0935e0111-e0,1,4*
      KEYBOARD_KEY_90001=forward
      KEYBOARD_KEY_90002=back
      KEYBOARD_KEY_90003=up
      KEYBOARD_KEY_90004=down
      KEYBOARD_KEY_90005=pageup
      KEYBOARD_KEY_90006=pagedown
      KEYBOARD_KEY_90007=home
      KEYBOARD_KEY_90008=end
  '';

  services.getty.extraArgs = [ "--nonewline" ];

  boot.kernel.sysctl."kernel.sysrq" = 1;

  fonts.packages = with pkgs; [ noto-fonts-cjk ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];

  security.pam.loginLimits = [
    { domain = "@users"; item = "memlock";  type = "-"; value = "unlimited"; }
    { domain = "@users"; item = "rtprio";   type = "-"; value = 95; }
    { domain = "@users"; item = "nice";     type = "-"; value = -19; }
  ];

  systemd.services.rtkit-daemon.serviceConfig.ExecStart = let
    rtkitConfig = {
      scheduling-policy = "FIFO";
      our-realtime-priority = 89;
      max-realtime-priority = 88;
      min-nice-level = -19;
      rttime-usec-max = 2000000;
      users-max = 100;
      processes-per-user-max = 1000;
      threads-per-user-max = 10000;
      actions-burst-sec = 10;
      actions-per-burst-max = 1000;
      canary-cheep-msec = 30000;
      canary-watchdog-msec = 60000;
    };
    cmdline = lib.cli.toGNUCommandLineShell {} rtkitConfig;
  in [
    ""
    "${pkgs.rtkit}/libexec/rtkit-daemon ${cmdline}"
  ];
}

