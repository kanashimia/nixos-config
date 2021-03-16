{ conf-utils, ... }:

{
  imports = conf-utils.listFiles ./.;
  _module.args.colors = {
    foreground = "d5d5e1";
    background = "202331";# "292d3e";
    
    black = "4e5471";
    red = "f07178";
    green = "c3e88d";
    yellow = "ffc47c";
    blue = "82aaff";
    purple = "c792ea";
    cyan = "89ddff";
    white = "d5d5e1";

    blackBr = "676e95";
    redBr = "f07178";
    greenBr = "c3e88d";
    yellowBr = "ffc47c";
    blueBr = "82aaff";
    purpleBr = "c792ea";
    cyanBr = "89ddff";
    whiteBr = "d5d5e1";
  };
}
