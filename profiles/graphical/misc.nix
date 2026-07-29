{ pkgs, lib, config, ... }: {
  users.users.kanashimia = {
    uid = 1000;
    description = "Kanashimia";
    home = "/home/kanashimia";
    # shell = config.users.defaultUserShell;
    # isSystemUser = true;
    isNormalUser = true;
    extraGroups = [ "wheel" "pipewire" ];
    # group = "users";
  };

  # nix.daemonIOSchedClass = "idle";
  # nix.daemonCPUSchedPolicy = "idle";

  environment.localBinInPath = true;
  environment.profiles = lib.mkForce [
    "/run/current-system/sw"
  ];

  programs.git = {
    enable = true;
    config = {
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
  };

  # environment.sessionVariables.DIRENV_CONFIG = "/etc/direnv";
  environment.etc = {
    "direnv/direnvrc".text = ''
      source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
    '';
  };

  services.speechd.enable = false;

  services.upower.enable = true;

  # services.kmscon = {
  #   enable = true;
  #   useXkbConfig = true;
  # };

  # programs.direnv = {
  #   enable = true;
  #   enableBashIntegration = false;
  #   enableZshIntegration = false;
  #   enableXonshIntegration = false;
  #   enableFishIntegration = false;
  #   nix-direnv.enable = true;
  # };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    direnv nix-direnv
    hydra-check

    # mypaint krita inkscape

    wlprop socat openssl wl-screenrec
    testssl

    quickshell

    # libreoffice

    ipcalc
    ripgrep fd tree dua nix-tree
    # du-dust
    pciutils usbutils htop-vim
    strace ltrace hyperfine
    # fwts
    lshw cpuid evtest nvme-cli hwinfo
    jq swaycwd watchexec file xdg-utils
    lsof hdparm yazi # chafa lf 
    unar
    dmidecode smartmontools
    iw
    perf
    libinput
    nmap
    wireguard-tools
    exiftool
    oha

    compsize
    e2fsprogs
    sysfsutils

    # direnv-instant

    impala
    iwgtk

    waybar

    ardour
    qpwgraph
    pwvucontrol
    # carla
    # musescore

    liquidsfz
    sfizz-ui # sfizz
    distrho-ports

    noise-repellent
    dragonfly-reverb
    x42-plugins
    zita-at1
    vocproc
    rubberband
    talentedhack
    speech-denoiser
    # aether-lv2
    boops
    rnnoise-plugin
    deepfilternet

    gxplugins-lv2
    zam-plugins #
    tap-plugins
    # lsp-plugins ##
    infamousPlugins
    # calf
    (stdenv.mkDerivation (self: {
      pname = "wolf-spectrum";
      version = "1.0.0";

      src = fetchFromGitHub {
        owner = "wolf-plugins";
        repo = "wolf-spectrum";
        rev = "b2188962d81a203f4e3c859dbdac5b4d58933591";
        hash = "sha256-fjpFJ8s/ELf3qrF+Mj0EQMRveEZV1XuEOAg7lSRWt48=";
        fetchSubmodules = true;
      };

      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ libjack2 lv2 libX11 liblo libGL libXcursor ];

      makeFlags = [
        "BUILD_LV2=true"
        "BUILD_VST2=true"
        "BUILD_JACK=true"
      ];

      patchPhase = ''
        patchShebangs ./dpf/utils/generate-ttl.sh
      '';

      installPhase = ''
        mkdir -p $out/lib/lv2
        mkdir -p $out/lib/vst
        mkdir -p $out/bin/
        cp -r bin/wolf-spectrum.lv2    $out/lib/lv2/
        cp -r bin/wolf-spectrum-vst.so $out/lib/vst/
        cp -r bin/wolf-spectrum        $out/bin/
      '';
    }))
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

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    # monaspace
    nerd-fonts.symbols-only
    nerd-fonts.ubuntu
    nerd-fonts.monaspace
    # corefonts
    # vistafonts
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    extraLv2Packages = with pkgs; [
      distrho-ports
    ];
    extraConfig.pipewire."99-professional-audio" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 256;
        "default.clock.force-quantum" = 256;
        "core.daemon" = true;
        "core.name" = "pipewire-0";
      };
    };
  };

  boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];

  # security.pam.loginLimits = [
  #   { domain = "*"; item = "memlock";  type = "-"; value = "unlimited"; }
  #   # { domain = "*"; item = "nofile";   type = "-"; value = "unlimited"; }
  #   { domain = "*"; item = "rtprio";   type = "-"; value = 95; }
  #   { domain = "*"; item = "nice";     type = "-"; value = -19; }
  # ];

  # systemd.services.rtkit-daemon.serviceConfig.ExecStart = let
  #   rtkitConfig = {
  #     scheduling-policy = "FIFO";
  #     our-realtime-priority = 89;
  #     max-realtime-priority = 88;
  #     min-nice-level = -19;
  #     rttime-usec-max = 2000000;
  #     users-max = 100;
  #     processes-per-user-max = 1000;
  #     threads-per-user-max = 10000;
  #     actions-burst-sec = 10;
  #     actions-per-burst-max = 1000;
  #     canary-cheep-msec = 30000;
  #     canary-watchdog-msec = 60000;
  #   };
  #   cmdline = lib.cli.toCommandLineShellGNU {} rtkitConfig;
  # in [
  #   ""
  #   "${pkgs.rtkit}/libexec/rtkit-daemon ${cmdline}"
  # ];

  boot.kernel.sysctl."kernel.dmesg_restrict" = false;

  services.syncthing = rec {
    enable = true;
    openDefaultPorts = true;

    user = "kanashimia";
    group = "users";
    dataDir = "/home/${user}";

    settings = {
      options = {
        urAccepted = -1; # no
      };
      devices = {
        # battleworn-phone.id = "XN3GANY-G7LQZU6-D73DSBJ-FCYMRHN-XGO6L3L-R6RJP64-GGNW4TX-VS2EXQF";
        xiaoxiao-tablet.id = "5KPJJZA-UB45DFH-CJQXCZQ-2YLFB2E-B6EWD7D-V7UI6HN-RF3G5MG-UXYEFQU";
        hp-laptop.id = "PUICPVJ-X345CLK-F4FTBBA-7LKLLMI-FAVGXYV-GE73Q2Y-I6WECLS-4YGWGQE";
      };
      folders = let
        basedConfig = { devices = lib.attrNames settings.devices; };
      in {
        "~/Sync" = { enable = false; };
        "~/music" = basedConfig;
        "~/documents" = basedConfig;
        # "documents" "pictures" "music" "projects"
      };
    };
  };
}

