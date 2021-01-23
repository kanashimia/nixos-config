{ pkgs, ... }:

{
  # Imagine humanity when this becomes usable.
  #
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   jack.enable = true;
  #   pulse.enable = true;
  # };

  # Enable ALSA
  sound.enable = true;

  # Enable PulseAudio
  hardware.pulseaudio.enable = true;

  # Enable JACK
  services.jack = {
    jackd.enable = true;
    alsa.enable = false;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol qjackctl
  ];
}
