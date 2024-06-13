{ pkgs, lib, config, ... }: {
  imports = [
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

  # systemd.tmpfiles.rules = [
  #   "w /sys/kernel/mm/lru_gen/min_ttl_ms - - - - 1000"
  # ];

  # systemd.extraConfig = ''
  #   DefaultOOMPolicy=continue
  # '';

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    mypaint krita

    libreoffice
    
    ripgrep fd tree dua nix-tree du-dust
    pciutils usbutils htop-vim
    strace ltrace hyperfine
    fwts lshw cpuid evtest nvme-cli hwinfo
    jq swaycwd watchexec file xdg-utils
    lsof chafa lf hdparm
    unar
    dmidecode smartmontools
    iw
    config.boot.kernelPackages.perf
    libinput
    nmap

    ardour
    qpwgraph
    carla
    musescore

    liquidsfz
    sfizz
    distrho

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
      buildInputs = [ libjack2 lv2 xorg.libX11 liblo libGL xorg.libXcursor ];

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

  fonts.packages = with pkgs; [ noto-fonts-cjk monaspace ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    extraLv2Packages = with pkgs; [
      distrho
    ];
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
        xiaoxiao-tablet.id = "XN3GANY-G7LQZU6-D73DSBJ-FCYMRHN-XGO6L3L-R6RJP64-GGNW4TX-VS2EXQF";
        hp-laptop.id = "PUICPVJ-X345CLK-F4FTBBA-7LKLLMI-FAVGXYV-GE73Q2Y-I6WECLS-4YGWGQE";
      };
      folders = {
        "~/Sync" = { enable = false; };
        "~/music" = { devices = lib.attrNames settings.devices; };
        # documents
        # pictures
        # projects
      };
      # folders = let
      #   emptyDefault = { Sync.enable = false; };
        # dirs = lib.genAttrs [
        #   "documents" "pictures" "music" "projects"
        # ] (folder: {
        #   enable = true;
        #   path = "~/${folder}";
        #   devices = lib.attrNames settings.devices;
        # });
      # in emptyDefault // dirs;
    };
  };
}

