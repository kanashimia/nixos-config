# zmodload zsh/datetime

# preexec() {
#     timer="$EPOCHREALTIME"
# }

precmd() { 
    # psvar[2]=''
    # if (( timer )); then
    #     local -rF elapsed=$(( EPOCHREALTIME - timer ))
    #     local -rF s=$(( elapsed % 60 ))
    #     local -ri m=$(( elapsed / 60 % 60 ))
    #     local -ri h=$(( elapsed / 3600 ))

    #     if (( h > 0 )); then
    #         psvar[2]=$(printf '%ih%im' ${h} ${m})
    #     elif (( m > 0 )); then
    #         psvar[2]=$(printf '%im%is' ${m} ${s})
    #     elif (( s >= 1 )); then
    #         psvar[2]=$(printf '%.2fs' ${s})
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
    PSVAR=''
}
# %(2V.took:%2v.)
PROMPT='
%F{cyan}%~%f %(2L.%F{red}lvl:%L%f .)%(1V.%F{yellow}git:%1v%f.)
%F{%(?.green.red)}%(!.!.›)%f '
