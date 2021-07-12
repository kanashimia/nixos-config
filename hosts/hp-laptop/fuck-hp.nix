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
  systemd.services.fuck-hp = {
    enable = true;
    description = "Fuck HP";
    script = ". /dev/input/js0; exit 0";
    wantedBy = [ "multi-user.target" ];
  };

  # Debugging for acpi.
  services.acpid.enable = true;
  environment.systemPackages = with pkgs; [ acpid ];

  # Backlight control.
  hardware.acpilight.enable = true;
  services.illum.enable = true;
  systemd.services.illum.serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";

  # And damn lid switch works unreliably af, only causes problems.
  services.logind.lidSwitch = "ignore";

  # In hope that this fixes something.
  boot.kernelParams = [
    "snd_hda_intel.model=hp-mute-led-mic3"
    "acpi=strict"
  ];
}
