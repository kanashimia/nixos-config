prompt_top_line=(
    '%F{cyan}%~%f'
    $'%(2L.%F{red}lvl:%L%f.\e[D)'
)
prompt_lines=(
    ''
    "${(j: :)prompt_top_line}"
    "%F{%(?.green.red)}%(!.!.›)%f"
)
prompt="${(F)prompt_lines}"
