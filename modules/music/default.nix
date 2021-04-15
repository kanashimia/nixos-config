{ pkgs, inputs, ...}:

let
distrho-overlay = final: prev: {
  distrho = prev.distrho.overrideAttrs (old: let
    rpathLibs = [ final.fftwFloat ];
  in {
    src = pkgs.fetchFromGitHub {
      owner = "DISTRHO";
      repo = "DISTRHO-Ports";
      rev = "52efe75c693ee567142212c505dd19568f01c458";
      sha256 = "ioQdCpugunuQ0XzFgxEcwnPkZM8ENcn6vQClycDlmX4=";
    };
    postFixup = ''
      for file in \
        "$out/lib/lv2/vitalium.lv2/vitalium.so" \
        "$out/lib/vst/vitalium.so" \
        "$out/lib/vst3/vitalium.vst3/Contents/x86_64-linux/vitalium.so"
      do
        patchelf --set-rpath "${final.lib.makeLibraryPath rpathLibs}:$(patchelf --print-rpath $file)" $file
      done
    '';
    buildInputs = old.buildInputs ++ rpathLibs;
  });
};
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

  #nixpkgs.overlays = [ distrho-overlay ];

  environment.systemPackages = with pkgs; [
    # Some programs
    ardour
    mixxx
    audacity
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
