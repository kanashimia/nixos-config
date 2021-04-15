{ pkgs, ... }:

let
config = pkgs.writeTextDir
  "/share/kak/autoload/kakrc.kak"
  (pkgs.lib.readFile ./config.kak);

kak-overlay = final: prev: {
  kakoune = prev.kakoune.override {
    plugins = with final; with kakounePlugins; [
      config kak-lsp kakoune-state-save
      nodePackages.svelte-language-server
    ];
  };
};
in
{
  nixpkgs.overlays = [ kak-overlay ];
  
  environment.systemPackages = with pkgs; [
    kakoune
    nodePackages.vscode-html-languageserver-bin
    nodePackages.vscode-json-languageserver-bin
    nodePackages.vscode-css-languageserver-bin
    #nodePackages.emmet-cli
    #nodePackages.emmet-ls
    nodePackages.svelte-language-server
    #emmet
  ];
  environment.variables.EDITOR = "kak";
}
