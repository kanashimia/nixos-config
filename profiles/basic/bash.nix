{
  programs.bash.promptInit = let
    mkColor = n: ''\e[${n}m'';
    clear = mkColor "";
    red = mkColor "31";
    cyan = mkColor "36";
    exitStatusColor = mkColor "3$((1+($?==0)))";
  in ''
    PS1='\n${cyan}\w${clear}'
    ((SHLVL > 1)) && PS1+='${red} lvl:$SHLVL${clear}'
    PS1+='\n${exitStatusColor}'
    (( UID == 0 )) && PS1+='!' || PS1+='›'
    PS1+='${clear} '
  '';

  # Support XDG base dir spec to some degree.
  programs.bash.interactiveShellInit = ''
    mkdir -p "''${XDG_STATE_HOME:-$HOME/.local/state}"/bash
    HISTFILE="$_"/history
    HISTSIZE=10000
    HISTFILESIZE=10000
    HISTCONTROL=ignoreboth:erasedups

    cd() { builtin cd "$@" && ls --color=tty -lAh --group-directories-first ; }
  '';
}
