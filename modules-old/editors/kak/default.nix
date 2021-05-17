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
      kakoune-idris
      idris2 nodejs
    ];
  };
};

inherit (pkgs.kakouneUtils) buildKakounePluginFrom2Nix;

kakoune-idris = buildKakounePluginFrom2Nix rec {
  pname = "kakoune-idris";
  version = "2020-12-29";

  src = pkgs.fetchFromGitHub {
    owner = "stoand";
    repo = pname;
    rev = "1acdfb5d89e3951ae4bdf4a5fa2377b36448083d";
    sha256 = "OUmzP9B98VUHIlFrROWs0LDdw+HeXaDlPi1JkA7yFhs=";
  };

  meta.homepage = "https://github.com/stoand/kakoune-idris";
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
