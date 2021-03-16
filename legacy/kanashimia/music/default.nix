{ pkgs, ...}:

let
distrho = pkgs.distrho.overrideAttrs (old: {
  src = pkgs.fetchFromGitHub {
    owner = "DISTRHO";
    repo = "distrho-ports";
    rev = "204d843be763eb018ef27e1f17c530bd7a523d2a";
    sha256 = "PGpXDLs+BOu7MdnbGahK0yraxiJrDTLX813K+KTGoxA=";
  };
  nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.fftwFloat.dev ];
  buildInputs = old.buildInputs ++ [ pkgs.fftwFloat.dev ];
});
plugins = with pkgs; [
  # Standalone synths
  zyn-fusion

  # Drums
  avldrums-lv2
  drumkv1
  hydrogen
  drumgizmo

  # Collections
  calf
  infamousPlugins
  zam-plugins
  x42-plugins
  tap-plugins
  lsp-plugins
  distrho

  # Reverbs
  fverb
  dragonfly-reverb
  hybridreverb2
  mooSpace

  # Equalisers
  eq10q

  # Pitch shifters
  rubberband
  vocproc

  # Distortion
  wolf-shaper
  guitarix
  gxplugins-lv2

  # Noise cancelation
  noise-repellent

  # Autotune
  zita-at1
];
in
{
  imports = [ ./player.nix ];

  environment.systemPackages = with pkgs; [
    # Some programs
    ardour
    mixxx
    audacity
    vcv-rack
    zyn-fusion
  ];

  environment.variables = {
    DSSI_PATH   = pkgs.lib.makeSearchPath "lib/dssi" plugins;
    LADSPA_PATH = pkgs.lib.makeSearchPath "lib/adspa" plugins;
    LV2_PATH    = pkgs.lib.makeSearchPath "lib/lv2" plugins;
    LXVST_PATH  = pkgs.lib.makeSearchPath "lib/lxvst" plugins;
    VST_PATH    = pkgs.lib.makeSearchPath "lib/vst" plugins;
    VST3_PATH   = pkgs.lib.makeSearchPath "lib/vst3" plugins;
  };
}
