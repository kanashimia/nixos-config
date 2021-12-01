{
  programs.bash.promptInit = let
    mkClr = n: ''\[\e[${n}m\]'';
    clear = mkClr "";
    red = mkClr "31";
    cyan = mkClr "36";
    exitStatusClr = mkClr "3$((1+($?==0)))";
  in ''
    PS1='\n${cyan}\w${clear}'
    ((SHLVL > 1)) && PS1+='${red} lvl:$SHLVL${clear}'
    PS1+='\n${exitStatusClr}'
    (( UID == 0 )) && PS1+='!' || PS1+='›'
    PS1+='${clear}'
  '';

  # Support XDG base dir spec to some degree.
  programs.bash.interactiveShellInit = ''
    mkdir -p "''${XDG_STATE_HOME:-$HOME/.local/state}"/bash
    HISTFILE="$_"/history
  '';
}
