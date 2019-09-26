# repos
# z.lua
if [[ ! -a $HOME/.dot/repos/z.lua ]]; then
  git clone -b 'v1.5.8' git@github.com:skywind3000/z.lua.git $HOME/.dot/repos/z.lua
fi
[[ -s $HOME/.dot/repos/z.lua/z.lua.plugin.zsh ]] && source $HOME/.dot/repos/z.lua/z.lua.plugin.zsh

# async prompt
[ -n "$ZSH_VERSION" ] && [ -s $HOME/.dot/prompt/setup.zsh ] && source $HOME/.dot/prompt/setup.zsh

# fzf
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
function zz() {
        local dir
        dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "$dir" || return 1
}

# alias
alias k=kubectl
alias ks='kubectl -n kube-system'
alias mk=minikube
alias mkl='minikube service list'
alias mkt='minikube -p tbw'
alias mktl='minikube -p tbw service list'
alias h=helm

[[ -s $HOME/.dot/zsh_completion.d/_minikube ]] && \
        source $HOME/.dot/zsh_completion.d/_minikube

# alias & func
whoseport () {
   lsof -i ":$1" | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn} LISTEN
}

alias nview='nvim -R'

alias ag="ag --color-path '1;34' --color-line-number '0;37' --color-match '0;32' --color --break --group --heading"

alias mocp="mocp -T green_theme"
alias ssh='TERM=xterm-256color ssh'

# fkill - kill processes - list only the ones you can kill. Modified the earlier script.
fkill() {
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi

    if [ "x$pid" != "x" ]
    then
        echo $pid | xargs kill -${1:-9}
    fi
}

alias fk='fkill'

