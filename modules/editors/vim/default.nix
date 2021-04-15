{ pkgs, ... }:

{
  programs.neovim = {
    enable = true; 
    configure = {
      customRC = ''
        " here your custom configuration goes!
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        # loaded on launch
        start = [ emmet-vim ];
        # manually loadable by calling `:packadd $plugin-name`
        opt = [ ];
      };
    };
  };
  environment.systemPackages = with pkgs; [ nodejs ];
}
