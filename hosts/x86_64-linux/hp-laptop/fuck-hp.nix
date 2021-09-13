{ pkgs, ... }:

{
  # Please, please never buy HP laptops,
  # especially if you are going to be using linux,
  # everything about their firmware makes me wanna cry.
  # Like why do my "function" keys don't function
  # unless i load device by hands, and, AND,
  # even then that device is there only half of the time,
  # and, if it isn't there (because probably it isn't),
  # you have to do a hard shutdown to make it appear.
  # Idk how to feel about this, sounds like a sitcom.
  #
  # Edit: Ah fuck, even this doesen't work anymore.
  # I'll keep it for historical reference.
  #
  # Wait it works again? Like wth. And now it doesen't, ok.
  # Also yes, it is indeed a problem with their DSDT.

  services.udev.extraRules = ''
    KERNELS=="lis3lv02d", TAG+="systemd", SYMLINK+="accel"
  '';
 
  systemd.services.fuck-hp = {
    enable = true;
    description = "Fuck HP";
    script = "sleep infinity 3< /dev/accel";
    after = [ "dev-accel.device" ];
    bindsTo = [ "dev-accel.device" ];
    wantedBy = [ "dev-accel.device" ];
  };

  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:bvn*:bvr*:bd*:br*:efr*:svnHP:pnHP15-cx00*:pvr*
      KEYBOARD_KEY_ab=unknown
      KEYBOARD_KEY_d8=unknown
  '';

  # Wait in hope that some updates will fix something (they will not).
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.zfs.enableUnstable = true;

  # Debugging for acpi.
  services.acpid.enable = true;
  environment.systemPackages = with pkgs; [ acpid ];
 
  # Backlight control.
  hardware.acpilight.enable = true;

  # So that mute led works.
  boot.kernelParams = [ "snd_hda_intel.model=hp-mute-led-mic3" ];
}
