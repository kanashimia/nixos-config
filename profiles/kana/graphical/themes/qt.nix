{ pkgs, ... }:

let
kvantum = pkgs.libsForQt5.qtstyleplugin-kvantum.overrideAttrs (old: {
  postPatch = old.postPatch + ''
    substituteInPlace kvantum.pro \
      --replace "kvantummanager" "" \
      --replace "kvantumpreview" "" \
      --replace "themes" ""
  '';
});
in
{
  home.packages = with pkgs; [ kvantum ];
  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORMTHEME = "gtk3";
  };
}
