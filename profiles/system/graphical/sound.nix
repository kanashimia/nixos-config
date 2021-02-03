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

  # Enable JACK
  services.jack = {
    jackd.enable = true;
    alsa.enable = false;
    loopback.enable = true;
  };

  environment.systemPackages = with pkgs; [
    qjackctl
  ];
}
