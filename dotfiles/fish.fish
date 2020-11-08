#set anime "\
#\e[34m     ____\e[0m
#\e[34m  .<.:.:\e[36m|>\e[34m\\>.\e[0m
#\e[34m /:メV/斗:+:X.\e[0m
#\e[36m<<\e[34m""Y\e[37m ¬  ⌐ \e[34m\:介\\\\\e[0m
#\e[34m|·|\e[37m⌒ __⌒  \e[34mV.\|\e[0m
#\e[34m| |\e[37m._\ノノ\e[34m「/!\e[0m
#\e[34m|.!\e[35m _\e[37m丁´l\e[35m_\e[34m!:_｣\e[0m
#\e[34m!:\e[35m/, (__ノ\e[34m|｛\e[35m\\\\\e[0m
#\e[34m|\e[35m/ (      \e[34m!,\e[35mへ\e[0m"
#IFS="" set anime (echo -e "$anime")

# if status is-login
# and test -z "$DISPLAY" -a "$XDG_VTNR" = 1
#     exec startx -- -keeptty &> ~/.xorg.log
# end

#if set -q DISPLAY
if status is-interactive
    if not set -q TMUX
        exec tmux
    end
    #IFS="" paste (printf "\n\n%b" (fortune | sed "s/^/  /" | expand) | psub) (echo $anime | psub) | column -s '$'\t -t
    #echo -e $anime
end
#    if string match -q "*scratchpad*" (xprop -id $WINDOWID WM_CLASS)
#    and test $LINES -gt 30 -a $COLUMNS -gt 100
#        set -l IFS ""
#        set -l A (fortune | sed -e "s/[[:cntrl:]]//g; s/^/  /" | expand)
#        paste (printf "\n\n%b" $A | psub) (echo $anime | psub) | column -s '$'\t -t
#    end
#end


# alias ls='exa --group-directories-first'
# alias ll='exa --group-directories-first -l --no-user --no-time'
# alias la='exa --group-directories-first -la --no-user --no-time'
# alias vifm='vifmrun'
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
# alias racket='rlwrap racket'
# alias vim='nvim'
# alias apl='apl -q --LX "]BOXING 8"'
# alias ranger='200iqfix & command ranger'
# alias info='info --vi-keys'

# alias code='code -r && code'

# abbr -g r 'ranger'
# 
# abbr -g g 'git'
# abbr -g gcl 'git clone'
# abbr -g gch 'git checkout'
# abbr -g gc 'git commit -m'
# abbr -g gi 'git init'
# 
# abbr -g p 'sudo pacman'
# abbr -g ps 'sudo pacman -S'
# abbr -g psu 'sudo pacman -Syu'
# abbr -g pr 'sudo pacman -Rsn'


# export LS_COLORS="rs=0:di=34:ln=36:mh=00:pi=40;33:so=35:do=35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=32:*.tar=31:*.tgz=31:*.arc=31:*.arj=31:*.taz=31:*.lha=31:*.lz4=31:*.lzh=31:*.lzma=31:*.tlz=31:*.txz=31:*.tzo=31:*.t7z=31:*.zip=31:*.z=31:*.dz=31:*.gz=31:*.lrz=31:*.lz=31:*.lzo=31:*.xz=31:*.zst=31:*.tzst=31:*.bz2=31:*.bz=31:*.tbz=31:*.tbz2=31:*.tz=31:*.deb=31:*.rpm=31:*.jar=31:*.war=31:*.ear=31:*.sar=31:*.rar=31:*.alz=31:*.ace=31:*.zoo=31:*.cpio=31:*.7z=31:*.rz=31:*.cab=31:*.wim=31:*.swm=31:*.dwm=31:*.esd=31:*.jpg=35:*.jpeg=35:*.mjpg=35:*.mjpeg=35:*.gif=35:*.bmp=35:*.pbm=35:*.pgm=35:*.ppm=35:*.tga=35:*.xbm=35:*.xpm=35:*.tif=35:*.tiff=35:*.png=35:*.svg=35:*.svgz=35:*.mng=35:*.pcx=35:*.mov=35:*.mpg=35:*.mpeg=35:*.m2v=35:*.mkv=35:*.webm=35:*.webp=35:*.ogm=35:*.mp4=35:*.m4v=35:*.mp4v=35:*.vob=35:*.qt=35:*.nuv=35:*.wmv=35:*.asf=35:*.rm=35:*.rmvb=35:*.flc=35:*.avi=35:*.fli=35:*.flv=35:*.gl=35:*.dl=35:*.xcf=35:*.xwd=35:*.yuv=35:*.cgm=35:*.emf=35:*.ogv=35:*.ogx=35:*.aac=36:*.au=36:*.flac=36:*.m4a=36:*.mid=36:*.midi=36:*.mka=36:*.mp3=36:*.mpc=36:*.ogg=36:*.ra=36:*.wav=36:*.oga=36:*.opus=36:*.spx=36:*.xspf=36:*.djvu=33:*.doc=33:*.docx=33:*.dvi=33:*.eml=33:*.eps=33:*.fotd=33:*.odp=33:*.odt=33:*.pdf=33:*.ppt=33:*.pptx=33:*.rtf=33:*.xls=33:*.xlsx=33:*#=01;30:*~=01;30:*.tmp=01;30:*.swp=01;30:*.swo=01;30:*.swn=01;30:*.bak=01;30:*.bk=01;30:"
# export EXA_COLORS="ur=34:uw=34:ux=34:ue=34:gr=36:gw=36:gx=36:tr=35:tw=35:tx=35:uu=37:da=37:xx=30:sn=32"
# 
# export FZF_DEFAULT_COMMAND="fd -d5 --color=always -E VSCodium -E discord -E firefox -E Steam -E .steam -E .cache -E Downloads -E .stack -E .racket -E cargo"
# export FZF_DEFAULT_OPTS='--no-extended --multi --ansi --color 16,bg+:#343b51,hl+:6,hl:6 --bind "tab:down,btab:up,ctrl-alt-j:toggle+down,ctrl-alt-k:toggle+up,ctrl-l:toggle" --cycle'
# export FZF_FIND_FILE_COMMAND="$FZF_DEFAULT_COMMAND --type f"
# export FZF_FIND_FILE_OPTS="--sort"
# export FZF_OPEN_COMMAND="$FZF_DEFAULT_COMMAND --hidden --type f"
# export FZF_CD_COMMAND="$FZF_DEFAULT_COMMAND --type d"
# export FZF_CD_WITH_HIDDEN_COMMAND="$FZF_CD_COMMAND --hidden"
# export FZF_REVERSE_ISEARCH_OPTS="+s"

# # export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

#export KAKOUNE_POSIX_SHELL='/bin/dash'

#export EDITOR='kak'


#export LESS_TERMCAP_mb=(set_color -o red) # begin blink
#export LESS_TERMCAP_md=(set_color cyan) # begin bold
#export LESS_TERMCAP_me=(set_color normal) # reset bold/blink
#export LESS_TERMCAP_so=(set_color -r white) # begin reverse video
#export LESS_TERMCAP_se=(set_color normal) # reset reverse video
#export LESS_TERMCAP_us=(set_color yellow) # begin underline
#export LESS_TERMCAP_ue=(set_color normal) # reset underline
#export LESS='--mouse --wheel-lines 3'
#export MANLESS=''

function _hist_sync --on-event=fish_prompt
    history merge
end

function expand_glob
    set -l tokens (eval string escape -- (commandline -ct))
    if set -q tokens[1]
        commandline -tr ""
        commandline -i -- "$tokens"
    end
end
bind -M insert \eg expand_glob


# bind -M insert ` complete-and-search
# bind --preset -M visual -k btab complete-and-search
bind -M insert \ef ranger
bind \ef ranger
# bind -M visual ` pager-toggle-search

# bind -M insert -k btab complete
# bind -M insert \t complete-and-search
# bind -M visual -k btab complete
# bind -M visual \t complete-and-search
# bind -k btab complete
# bind \t complete-and-search
