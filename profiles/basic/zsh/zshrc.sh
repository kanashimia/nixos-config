ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
mkdir -p "$ZDOTDIR"

HISTFILE="$ZDOTDIR/history"
HISTSIZE=10000
SAVEHIST="$HISTSIZE"

setopt hist_ignore_all_dups hist_ignore_space
# hist_find_no_dups hist_save_no_dups 
autoload -Uz compinit

zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
compinit -C -d "$zcompdump"
if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
fi
 
# Compile zcompdump, if modified, to increase startup speed.
# Execute in the background to not affect the current session
compinit -d "$zcompdump" &!

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%F{blue}Completing %F{yellow}%d%f%b'

eval "$(dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# print dir contents after each dir change
chpwd() {
    ls --color=tty -lAh --group-directories-first
}

KEYTIMEOUT=0
WORDCHARS='*?_-~=&;!$'

unalias run-help
autoload run-help run-help-git run-help-nix run-help-sudo

setopt auto_continue

fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    zle push-input
    BUFFER="disown"
    zle accept-line
  else
    zle push-input
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "$key[Up]" up-line-or-beginning-search
bindkey "$key[Down]" down-line-or-beginning-search
