{ pkgs, lib, config, inputs, ... }: let
  wrapBinScript = pkg: script: pkgs.symlinkJoin {
    inherit (pkg) pname version meta;
    paths = [
      (pkgs.writeShellScriptBin (pkg.meta.mainProgram) (script + ''
        exec ${lib.getExe pkg} "$@"
      ''))
      pkg
    ];
    PKG = pkg;
    postBuild = ''
      if [ -L "$out/share/applications" ]; then
        rm "$out/share/applications"
        cp --no-preserve=mode,ownership -LR $PKG/share/applications $out/share/applications
      fi
      for EXEC in $out/bin/*; do
        for FILE in $out/share/applications/*; do
          if [ -L "$FILE" ]; then
            cp --remove-destination "$(readlink "$FILE")" "$FILE"
          fi
          sed -i "s|$PKG/bin/$(basename "$EXEC")|$EXEC|" "$FILE"
        done
      done
    '';
  };
in {
  # boot.kernel.sysfs.devices.system.cpu.intel_pstate.no_turbo = true;

  # systemd.user.services."sway-assign-cgroups" = {
  #   enable = false;
  #   after = [ "systemd.service" ];
  #   wantedBy = [ "sway.target" ];
  #   partOf = [ "graphical-session.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = lib.getExe pkgs.sway-assign-cgroups;
  #   };
  # };

  # Starting v258 systemd-journal-upload custom HTTP headers and compression are supported
  # Header=AccountID: 5
  # Header=ProjectID: 10
  # Compression=zstd:4 lz4:2

  # hardware.opentabletdriver.enable = true;
  # boot.loader.systemd-boot.memtest86.enable = true;

  # services.scx.extraArgs = [ "--autopower" ];

  services.scx.scheduler = "scx_lavd";
  services.scx.extraArgs = [ "--performance" ];

  # services.scx.scheduler = "scx_bpfland";
  # services.scx.extraArgs = [ "-m" "performance" ];

  # services.scx.enable = true;
  # systemd.services.scx = {
  #   before = [ "sleep.target" ];
  #   conflicts = [ "sleep.target" ];
  # };
  # systemd.targets.sleep = {
  #   onSuccess = [ "scx.service" ];
  #   onFailure = [ "scx.service" ];
  # };

  # systemd.settings.Manager = {
  #   DefaultEnvironment = "PATH=${pkgs.mimalloc}/lib/libmimalloc.so";
  # };

  # environment.memoryAllocator.provider = "mimalloc";
  # nixpkgs.overlays = [ (final: prev: {
  #   chromium = wrapBinScript prev.chromium ''
  #     export LD_PRELOAD=libc.so.6:${pkgs.jemalloc}/lib/libjemalloc.so
  #   '';
  #   vivaldi = wrapBinScript prev.vivaldi ''
  #     export LD_PRELOAD=libc.so.6:${pkgs.jemalloc}/lib/libjemalloc.so
  #   '';
  #   firefox-devedition = wrapBinScript prev.firefox-devedition ''
  #     export LD_PRELOAD=libc.so.6:${pkgs.jemalloc}/lib/libjemalloc.so
  #   '';
  #   thunderbird = wrapBinScript prev.thunderbird ''
  #     export LD_PRELOAD=libc.so.6:${pkgs.jemalloc}/lib/libjemalloc.so
  #   '';
  # }) ];

  # environment.memoryAllocator.provider = "jemalloc";

  # environment.etc."ld-nix.so.preload".text = ''
  #   ${pkgs.snmalloc}/lib/libsnmallocshim-checks.so
  # '';

  # environment.sessionVariables.MIMALLOC_PURGE_DELAY = "1";

  # environment.memoryAllocator.provider = "jemalloc";

  networking.wireless.iwd.enable = true;

  # programs.adb.enable = true;

  boot.initrd.kernelModules = [ "nvme" ];

  boot.loader.systemd-boot.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      AlwaysPairable = true;
      FastConnectable = true;
      Privacy = "off";
      JustWorksRepairing = "always";
    };
  };

  #   Policy = {
  #     ResumeDelay = 0;
  #     ReconnectAttempts = 30;
  #   #   ReconnectIntervals = "1";
  #     AutoEnable = true;
  #   };
  # hardware.bluetooth.input = {
  #   General = {
  # #     IdleTimeout = 0;
  #     # UserspaceHID = "persist";
  #     UserspaceHID = false;
  #   };
  # };

  # Whatever bug with bcachefs
  # systemd.tmpfiles.rules = [
  #   "w /sys/block/nvme0n1/queue/max_sectors_kb - - - - 64"
  # ];

  # boot.supportedFilesystems = [ "bcachefs" "btrfs" "ext4" "xfs" ];

  environment.systemPackages = with pkgs; [
    # solaar vial
    prismlauncher
    android-tools
  ];
  hardware.logitech.wireless.enable = true;

  fileSystems = {
    "/" = {
      label = "iris";
      fsType = "btrfs";
      options = [ "subvol=root" "noatime" "compress=lzo" ];
    };
    "/nix" = {
      label = "iris";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress=lzo" ];
    };
    "/home" = {
      label = "iris";
      fsType = "btrfs";
      options = [ "subvol=home" "noatime" "compress=lzo" ];
    };
    "/boot" = {
      label = "boot";
      options = [ "x-systemd.automount,x-systemd.idle-timeout=5" ];
      fsType = "vfat";
    };
  };

  systemd.services."btrfs-snapshot-home" = {
    after = [ "local-fs.target" ];
    script = ''
      export PATH="${pkgs.btrfs-progs}/bin:$PATH"
      SNAPSHOT_DIR="/snapshots/home"
      mkdir -p "$SNAPSHOT_DIR"
      cd "$SNAPSHOT_DIR"
      ls -r | tail -n +100 | xargs -I {} btrfs subvolume delete {}
      btrfs subvolume snapshot -r "/home" "$(date --iso-8601=seconds)"
    '';
    startAt = "*:0/30";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      nvidia-vaapi-driver
      # vaapiVdpau
      # libvdpau-va-gl
    ];
  };

  programs.steam.enable = true;
  boot.kernelModules = [ "ntsync" ];

  nixpkgs.config.allowUnfree = true;
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  services.logind.settings.Login = {
    IdleAction = "suspend";
    IdleActionSec = "10min";
  };

  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:bvn*:bvr*:bd*:br*:efr*:svnHP:pnHP15-cx00*:pvr*
    evdev:atkbd:dmi:bvn*:bvr*:bd*:svnHP*:pn*:*
       KEYBOARD_KEY_ab=unknown
  '';

  # powerManagement.powertop.enable = false;

  # services.tuned.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      DISK_SPINDOWN_TIMEOUT_ON_AC = "keep 1";
      DISK_SPINDOWN_TIMEOUT_ON_BAT = "keep 1";

      DISK_APM_LEVEL_ON_BAT = "keep 127";
      DISK_APM_LEVEL_ON_AC = "keep 127";

      SATA_LINKPWR_ON_AC = "med_power_with_dipm min_power";
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm min_power";

      AHCI_RUNTIME_PM_ON_AC="on";
      AHCI_RUNTIME_PM_ON_BAT="on";

      AHCI_RUNTIME_PM_TIMEOUT = "6";

      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  services.udev.packages = let
    udevRule = name: text: pkgs.writeTextFile {
      inherit name text;
      destination = "/etc/udev/rules.d/${name}.rules";
    };
  in lib.mapAttrsToList udevRule {
    "60-i915-perf-paranoid" = ''
      SUBSYSTEM=="pci", DRIVER=="i915", SYSCTL{dev.i915.perf_stream_paranoid}="0"
    '';
    "60-gpu-dri-alias" = ''
      SUBSYSTEM=="drm", SYMLINK=="dri/by-path/pci-0000:00:02.0-card", SYMLINK+="dri/intel", TAG+="systemd"
      SUBSYSTEM=="drm", SYMLINK=="dri/by-path/pci-0000:01:00.0-card", SYMLINK+="dri/nvidia", TAG+="systemd"
    '';
    "90-lowbat" = ''
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-9]", \
        RUN+="${config.systemd.package}/bin/systemctl suspend -i"
    '';
    "80-usb-automount" = ''
      ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", \
        RUN{program}+="${config.systemd.package}/bin/systemd-mount --owner kanashimia --no-block -AG $devnode"
    '';
    "50-arduino-promicro-flash-access" = ''
      KERNEL=="ttyACM*", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9205", MODE="0660", TAG+="uaccess"
    '';
    "50-supermini-promicro-flash-access" = ''
      KERNEL=="ttyACM*", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="615e", MODE="0660", TAG+="uaccess"
    '';
    "90-logi-bolt-wakeup" = ''
      ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", ATTR{power/wakeup}="disabled"
    '';
    "69-hd-spindown" = ''
      ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd*", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -B 127 -S 2 $devnode"
    '';
    # "72-remove-access-permissions" = ''
    #   KERNEL=="video*", TAG-="uaccess"
    # '';
  } ++ (with pkgs; [
    # vial
  ]);

  # boot.kernelPatches = [{
  #   name = "custom-kernel-config";
  #   patch = null;
  #   extraStructuredConfig = with lib.kernel; {
  #     PREEMPT_RT = yes;
  #     EXPERT = yes;
  #     PREEMPT_VOLUNTARY = lib.mkForce no;
  #     DRM_I915_GVT = lib.mkForce {};
  #     DRM_I915_GVT_KVMGT = lib.mkForce {};
  #   };
  # }];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_testing;
  # boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [
    # "apm=off"
    # "mitigations=off"

    # "i915.enable_psr=0"

    # pcie_aspm=force

    "preempt=full"
    "threadirqs"

    # "nohz=on"

    # "nohz_full=all"

    # "rcu_nocbs=all"
    # "rcutree.enable_rcu_lazy=1"

    # "memmap=0x2000$0x0001e2c2f000"
    # "memmap=0x2000$0x0001e6c2f000"
    # "memmap=0x10000$0x0001e2c20000"
    # "memmap=0x1000$0x0001e2c30000"
    # "memmap=0x1000$0x0001e6c30000"
    # "snd_hda_intel.model=hp-mute-led-mic3" # Mute led fix.
    # "snd_hda_intel.model=103c:820d" # Mute led fix.
    # "snd_hda_intel.model=,103c:820d" # Mute led fix.
    # "bgrt_disable"
    # "usbcore.autosuspend=-1"
    # "btusb.enable_autosuspend=0"

    # "quiet splash loglevel=3 systemd.show_status=false udev.log_level=3 rd.udev.log_level=3"

    # "quiet" "splash" "systemd.show_status=false" "udev.log_level=3"
    # "vt.global_cursor_default=0"
  ];

  # options i915 enable_guc=2
  boot.extraModprobeConfig = ''
    options snd_hda_intel model=,103c:820d
  '';

  # Hide ACPI error messages.
  boot.consoleLogLevel = 3;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "22.05";
}
