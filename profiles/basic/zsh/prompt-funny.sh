# zmodload zsh/datetime

precmd=()
precmd_functions=()
unset -f precmd 2>/dev/null

preexec=()
preexec_functions=()
unset -f preexec 2>/dev/null

chpwd=()
chpwd_functions=()
unset -f chpwd 2>/dev/null

unset PROMPT

preexec() {
    print -n '\e]133;C\e\\'
    # timer="$EPOCHREALTIME"
}

COOL_PROMPT="\
<span foreground='#89ddff'>%~</span> \
%(2L.<span foreground='#f07178'>lvl:%L</span> .)\
%(1V.<span foreground='#ffc47c'>git:%1v</span> .)\
%(2V.<span foreground='#f07178'>ssh:%n@%M</span> .)\
%(3V.<span foreground='#f07178'>env:%3v</span> .)\
"


precmd() { 
    print -n '\e]133;D\e\\'
    print -n '\e]133;A\e\\'

    psvar=()

    # if (( timer )); then
    #     local -rF elapsed=$(( EPOCHREALTIME - timer ))
    #     local -rF s=$(( elapsed % 60 ))
    #     local -ri m=$(( elapsed / 60 % 60 ))
    #     local -ri h=$(( elapsed / 3600 ))
    #     if (( h > 0 )); then
    #         psvar[3]="$(printf '%ih%im' ${h} ${m})"
    #     elif (( m > 0 )); then
    #         psvar[3]="$(printf '%im%is' ${m} ${s})"
    #     elif (( s >= 1 )); then
    #         psvar[3]="$(printf '%.2fs' ${s})"
    #     fi
    # fi
    # unset timer

    psvar[3]="${DIRENV_DIR##*/}"

    psvar[2]="$SSH_TTY"

    local PATH="$PWD"
    local -i i
    for ((i=0; i <= 10; i++)); do
        if [[ -e "$PATH/.git" ]]; then
            local FILE="$PATH"/.git/HEAD
            if [[ -f "$FILE" ]]; then
                local GIT_REF="$(< "$FILE")" 
                psvar[1]="${GIT_REF#ref: refs/heads/}"
                break
            fi
            local FILE="$PATH"/.git
            if [[ -f "$FILE" ]]; then
                local GIT_REF="$(< "$FILE")" 
                psvar[1]="${GIT_REF#gitdir: */.git/}"
                break
            fi
        fi
        PATH+='/..'
    done

    print -Pn "\e]2;$COOL_PROMPT\e\\"
}
# zle -N zle-line-init _my_precmd

# %(3V.took:%3v.)\

PROMPT="\
%F{%(?.green.red)}%(!.!.›)%f "

