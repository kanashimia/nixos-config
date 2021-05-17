set global ui_options ncurses_assistant=cat
add-highlighter global/custom group -passes colorize|move|wrap
add-highlighter global/custom/number-lines number-lines -hlcursor

eval %sh{ kak-lsp --kakoune -s $kak_session | sed 's/%reg{a}/<c-r>a/g' }
lsp-enable

map global user l %{: enter-user-mode lsp<ret>} -docstring "LSP mode"
map global user <minus> ':enter-user-mode idris-ide<ret>'
