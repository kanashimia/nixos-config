{ pkgs, ... }:

{
  # Imagine humanity when this becomes usable.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  # security.rtkit.enable = true;
  systemd.services.rtkit-daemon.serviceConfig.ExecStart = [
    ""
    "${pkgs.rtkit}/libexec/rtkit-daemon --our-realtime-priority=95 --max-realtime-priority=90"
  ];


  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"   ; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio" ; type = "-"   ; value = "99"       ; }
    { domain = "@audio"; item = "nofile" ; type = "soft"; value = "99999"    ; }
    { domain = "@audio"; item = "nofile" ; type = "hard"; value = "99999"    ; }
  ];

  # Enable ALSA
  sound.enable = true;
  #hardware.pulseaudio.enable = true;

  ## Enable JACK
  #services.jack = {
  #  jackd.enable = true;
  #  alsa.enable = false;
  #  loopback.enable = true;
  #};

  services.jack.jackd.extraOptions = [ "-R" "-P99" "-dalsa" ];

  environment.systemPackages = with pkgs; [
    patchage pavucontrol # qjackctl
  ];
}
