{ pkgs, ...}:

let
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
in {
  environment.systemPackages = with pkgs; [
    ardour
    patchage
  ];

  environment.variables = {
    DSSI_PATH   = pkgs.lib.makeSearchPath "lib/dssi" plugins;
    LADSPA_PATH = pkgs.lib.makeSearchPath "lib/ladspa" plugins;
    LV2_PATH    = pkgs.lib.makeSearchPath "lib/lv2" plugins;
    LXVST_PATH  = pkgs.lib.makeSearchPath "lib/lxvst" plugins;
    VST_PATH    = pkgs.lib.makeSearchPath "lib/vst" plugins;
    VST3_PATH   = pkgs.lib.makeSearchPath "lib/vst3" plugins;
  };
}
