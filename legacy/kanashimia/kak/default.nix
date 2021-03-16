{ pkgs, ... }:

let
config = pkgs.writeTextDir
  "/share/kak/autoload/kakrc.kak"
  (pkgs.lib.readFile ./config.kak);
kak = pkgs.kakoune.override {
  plugins = with pkgs.kakounePlugins; [
    config
  ];
};
in
{
  environment.systemPackages = with pkgs; [
    kak kak-lsp
  ];
  environment.sessionVariables = {
    EDITOR = "kak";
  };
}
