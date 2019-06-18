# shell configures, both zsh & bash

[[ ":$PATH:" != *":$HOME/bin:"* ]] && PATH="$HOME/bin:${PATH}"

# proxy
if [ -f $HOME/.dot/proxy.default ]; then
    . $HOME/.dot/proxy.default
fi

[[ -s "$HOME/.dot/proxy" ]] && source $HOME/.dot/proxy

[[ -s "$HOME/.dot/os.spec" ]] && source $HOME/.dot/os.spec

# dev env
[[ -s "$HOME/.dot/devenv" ]] && source $HOME/.dot/devenv

# fasd
# eval "$(fasd --init auto)"

# alias
# alias a='fasd -a'        # any
# alias s='fasd -si'       # show / search / select
# alias d='fasd -d'        # directory
# alias f='fasd -f'        # file
# alias sd='fasd -sid'     # interactive directory selection
# alias sf='fasd -sif'     # interactive file selection
# alias z='fasd_cd -d'     # cd, same functionality as j in autojump
# alias zz='fasd_cd -d -i' # cd with interactive selection
# alias zz='zz'

alias e='TERM=screen-16color emacsclient -nw'
# alias em='TERM=screen-16color emacs -nw'
alias em='emacs -nw'
alias ec='emacsclient -c'

alias vi='nvim'
alias nvi='nvim'

alias za='zathura --fork $@'

alias lg='lazygit'

# fzf
_gen_fzf_default_opts() {

local color00='#fdf6e3'
local color01='#eee8d5'
local color02='#93a1a1'
local color03='#839496'
local color04='#657b83'
local color05='#586e75'
local color06='#073642'
local color07='#002b36'
local color08='#dc322f'
local color09='#cb4b16'
local color0A='#b58900'
local color0B='#859900'
local color0C='#2aa198'
local color0D='#268bd2'
local color0E='#6c71c4'
local color0F='#d33682'

export FZF_DEFAULT_OPTS="
  --height 40% --border
  --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D
  --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C
  --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D
"
}

# _gen_fzf_default_opts
export FZF_DEFAULT_OPTS='
  --color fg:240,bg:230,hl:33,fg+:241,bg+:221,hl+:33
  --color info:33,prompt:33,pointer:166,marker:166,spinner:33
'

[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
function zz() {
        local dir
        dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "$dir" || return 1
}

# history size
export HISTSIZE=200000

# not to be disturbed by Ctrl-S ctrl-Q in terminals:
stty -ixon

# load tool
case $SHELL in
*/zsh)
  [ -f $HOME/.dot/tools.zsh ] && source $HOME/.dot/tools.zsh
  ;;
*/bash)
   # assume Bash
   ;;
*)
   # assume something else
esac

[ -s $HOME/.cht.sh ] && alias c='cht.sh'

if [ -f /usr/bin/src-hilite-lesspipe.sh ]; then
    export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
    export LESS=" -R "
    export LESS_TERMCAP_so=$'\E[43;30m'
fi

# plan9 dircolor
if [ -f $HOME/.dot/PLAN9_DIR_COLOR ]; then
     eval $( dircolors -b $HOME/.dot/PLAN9_DIR_COLOR)
fi

# repos

# z.lua
if [[ ! -a $HOME/.dot/repos/z.lua ]]; then
  git clone -b 'v1.5.8' git@github.com:skywind3000/z.lua.git $HOME/.dot/repos/z.lua
fi
[[ -s $HOME/.dot/repos/z.lua/z.lua.plugin.zsh ]] && source $HOME/.dot/repos/z.lua/z.lua.plugin.zsh

# zsh-async
if [[ ! -a $HOME/.dot/repos/zsh-async ]]; then
  git clone -b 'v1.7.1' git@github.com:mafredri/zsh-async $HOME/.dot/repos/zsh-async
fi
[ -n "$ZSH_VERSION" ] && source $HOME/.dot/repos/zsh-async/async.zsh && async_init

# async prompt
[ -n "$ZSH_VERSION" ] && [ -s $HOME/.dot/prompt/setup.zsh ] && source $HOME/.dot/prompt/setup.zsh

# LESS
export LESS_TERMCAP_mb=$'\E[1m\E[32m'
export LESS_TERMCAP_mh=$'\E[2m'
export LESS_TERMCAP_mr=$'\E[7m'
export LESS_TERMCAP_md=$'\E[1m\E[36m'
export LESS_TERMCAP_ZW=""
export LESS_TERMCAP_us=$'\E[4m\E[1m\E[37m'
export LESS_TERMCAP_me=$'\E(B\E[m'
export LESS_TERMCAP_ue=$'\E[24m\E(B\E[m'
export LESS_TERMCAP_ZO=""
export LESS_TERMCAP_ZN=""
export LESS_TERMCAP_se=$'\E[27m\E(B\E[m'
export LESS_TERMCAP_ZV=""
export LESS_TERMCAP_so=$'\E[1m\E[33m\E[44m'
