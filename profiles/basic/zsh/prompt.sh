# zmodload zsh/datetime

preexec() {
    print -n '\e]133;C\e\\'
    # timer="$EPOCHREALTIME"
}

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

    local PATH="$PWD"
    local -i i
    for i in {1..10}; do
        local HEAD_PATH="$PATH"/.git/HEAD
        if [[ -e "$HEAD_PATH" ]]; then
            local GIT_HEAD="$(< "$HEAD_PATH")" 
            psvar[1]="${GIT_HEAD#ref: refs/heads/}"
            return
        fi
        PATH+='/..'
    done
    psvar[2]="$SSH_TTY"
}

# %(3V.took:%3v.)\

PROMPT="\

%F{cyan}%~%f \
%(2L.%F{red}lvl:%L%f .)\
%(1V.%F{yellow}git:%1v%f .)\
%(2V.%F{green}ssh:%n@%M%f .)\

%F{%(?.green.red)}%(!.!.›)%f "

