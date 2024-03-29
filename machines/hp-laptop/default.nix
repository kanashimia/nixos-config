{ pkgs, lib, config, inputs, ... }: {
  imports = [ ./nvidia.nix ];

  networking.wireless.iwd.enable = true;

  programs.adb.enable = true;

  boot.initrd.kernelModules = [ "nvme" ];

  boot.loader.systemd-boot.enable = true;

  fileSystems = {
    "/" = {
      label = "iris";
      fsType = "btrfs";
      options = [ "subvol=root" "noatime" ];
    };
    "/nix" = {
      label = "iris";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" ];
    };
    "/home" = {
      label = "iris";
      fsType = "btrfs";
      options = [ "subvol=home" "noatime" ];
    };
    "/boot" = {
      label = "boot";
      fsType = "vfat";
    }; 
  };

  environment.systemPackages = with pkgs; [ compsize ];

  systemd.services."btrfs-snapshot-home" = {
    after = [ "local-fs.target" ];
    script = ''
      export PATH="${pkgs.btrfs-progs}/bin:$PATH"
      SNAPSHOT_DIR="/snapshots/home"
      mkdir -p "$SNAPSHOT_DIR"
      cd "$SNAPSHOT_DIR"
      ls -r | tail -n +10 | xargs -I {} btrfs subvolume delete {}
      btrfs subvolume snapshot -r "/home" "$(date --iso-8601=seconds)"
    '';
    startAt = "*:0/15";
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      nvidia-vaapi-driver
    ];
  };

  programs.steam.enable = true;

  nixpkgs.config.allowUnfree = true;
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  services.logind.extraConfig = ''
    IdleAction=suspend
    IdleActionSec=10min
  '';

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:bvn*:bvr*:bd*:br*:efr*:svnHP:pnHP15-cx00*:pvr*
    evdev:atkbd:dmi:bvn*:bvr*:bd*:svnHP*:pn*:*
       KEYBOARD_KEY_ab=unknown
  '';

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
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-15]", \
        RUN+="${config.systemd.package}/bin/systemctl suspend -i"
    '';
    "80-usb-automount" = ''
      ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", \
        RUN{program}+="${config.systemd.package}/bin/systemd-mount --owner kanashimia --no-block -AG %N"
    '';
    "50-arduino-promicro-flash-access" = ''
      KERNEL=="ttyACM*", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9205", MODE="0660", TAG+="uaccess"
    '';
  };

  boot.kernelParams = [
    "mitigations=off"
    "preempt=full"
    "snd_hda_intel.model=hp-mute-led-mic3" # Mute led fix.
  ];

  # Hide ACPI error messages.
  boot.consoleLogLevel = 3;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "22.05";
}
