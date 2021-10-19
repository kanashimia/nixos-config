{
  programs.bash.promptInit = ''
    CLR="\[$(tput sgr0)\]"
    RED="\[$(tput setaf 1)\]"
    GRN="\[$(tput setaf 2)\]"
    CYN="\[$(tput setaf 6)\]"

    PS1='\n'
    PS1+=$CYN'\w'$CLR
    ((SHLVL > 1)) && PS1+=$RED' nested'$CLR
    PS1+='\n'
    PS1+='$((( $? == 0 )) && echo '$GRN' || echo '$RED')'
    (( UID == 0 )) && PS1+='!' || PS1+='›'
    PS1+=$CLR

    unset CLR RED GRN CYN
  '';
}
