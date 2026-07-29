# zmodload zsh/zprof

ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
mkdir -p "$ZDOTDIR"

HISTFILE="$ZDOTDIR/history"
HISTSIZE=10000
SAVEHIST=10000

# setopt hist_ignore_dups hist_fcntl_lock share_history
setopt hist_ignore_dups hist_fcntl_lock
setopt hist_ignore_all_dups hist_ignore_space

typeset -U fpath
# for p in ${(@s/:/)XDG_DATA_DIRS}; do  
#   fpath+=($p/zsh/site-functions $fpath)
# done
for p in ${(z)NIX_PROFILES}; do
  fpath+=($p/share/zsh/site-functions $p/share/zsh/$ZSH_VERSION/functions $p/share/zsh/vendor-completions)
done
for p in ${(z@)path%/bin}; do
  fpath+=($p/share/zsh/site-functions $p/share/zsh/$ZSH_VERSION/functions $p/share/zsh/vendor-completions)
done
local -a valid_files
for f in $fpath; do
  [[ -e "$f" ]] && valid_files+=("$f")
done
fpath=("${valid_files[@]}")
unset valid_files 

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

function _force_rehash {
  (( CURRENT == 1 )) && rehash
  return 1
}

command_not_found_handler() {
  emulate -L zsh
  if [[ ! -n "$compstate" ]]; then
    echo "zsh: wtf command not found: $@"
  fi
  return 127
}

zstyle ':completion:*' completer _complete _ignored _match _correct _approximate _prefix _value
# zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu yes select
zstyle ':completion:*' group-name ''
# zstyle ':completion:*' single-ignored menu
zstyle ':completion:*:descriptions' format '%B%F{blue}Completing %F{yellow}%d%f%b'

eval "$(dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# print dir contents after each dir change
# chpwd() {
#   # ls --color=tty -lAh --group-directories-first
# }

KEYTIMEOUT=0
WORDCHARS='*?_-~=&;!$'

unalias run-help 2>/dev/null
autoload -Uz run-help run-help-git run-help-nix run-help-sudo
# zle -A run-help man
# bindkey "^[h" man

setopt auto_continue

fancy-ctrl-z() {
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

compdef -d hx
compdef -d typst

autoload -Uz add-zsh-hook

if (( EUID != 0 )) && hash direnv 2> /dev/null; then
  _direnv_hook() {
    trap -- '' SIGINT
    eval "$(direnv export zsh)"
    trap - SIGINT
  }
  direnv_invalidate_cache() {
    local cache_file=${DIRENV_CACHE_FILE:?"Cache file required"}
    rm "$cache_file"
    direnv reload
    _direnv_hook
    echo "recreated cache"
  }
  add-zsh-hook -Uz chpwd _direnv_hook
  _direnv_hook
fi

function xterm_title_precmd () {
	print -Pn -- '\e]2;%~\a'
}

function xterm_title_preexec () {
	print -Pn -- '\e]2;%~' && print -n -- "${(q)1}\a"
}

if [[ "$TERM" == (Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|screen*|wezterm*|tmux*|xterm*) ]]; then
	add-zsh-hook -Uz precmd xterm_title_precmd
	add-zsh-hook -Uz preexec xterm_title_preexec
fi
