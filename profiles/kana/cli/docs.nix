{ pkgs, ... }:

let
docs = pkgs.writeShellScriptBin "docs" ''
  AWK_SCRIPT='
  /^(NixOS|HomeManager) Options/ {
    getline;
    getline;
    print $2
  }'
  
  PREVIEW_SCRIPT='
  ${pkgs.unstable.manix}/bin/manix -s {} |
  ${pkgs.gnused}/bin/sed "s/type: /> type: /g" |
  ${pkgs.bat}/bin/bat -l Markdown --color=always --plain --theme=base16'

  ${pkgs.unstable.manix}/bin/manix "" |
  ${pkgs.gawk}/bin/awk "$AWK_SCRIPT" |
  ${pkgs.fzf}/bin/fzf --preview="$PREVIEW_SCRIPT" --preview-window=wrap
'';
in
{
  home.packages = with pkgs; [ docs ];
}
