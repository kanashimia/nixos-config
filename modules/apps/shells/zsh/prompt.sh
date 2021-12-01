precmd() {
    # local head
    # local path="$PWD"
    # while [[ "$path" != "" && ! -e "$path"/.git/HEAD ]]; do
    #     path="${path%/*}"
    # done
    # if [[ "$path" != "" ]]; then
    #   read head < "$path"/.git/HEAD
    #   head="${head##ref: refs/heads/}"
    # fi

    prompt_top_line=(
        '%F{cyan}%~%f'
        $'%(2L.%F{red}lvl:%L%f.\e[D)'
        # "%F{green}${head:+branch:$head}%f"
    )
    prompt_lines=(
        ''
        "${(j: :)prompt_top_line}"
        "%F{%(?.green.red)}%(!.!.›)%f"
    )
    PS1="${(F)prompt_lines}"
}
