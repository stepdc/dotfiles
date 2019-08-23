# repos
# fzf
[ -f $HOME/.fzf.bash ] && source $HOME/.fzf.bash
function zz() {
        local dir
        dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "$dir" || return 1
}

export LS_OPTIONS='--color=auto'

# alias
alias k=kubectl
alias ks='kubectl -n kube-system'
alias mk=minikube
alias mkl='minikube service list'
alias mkt='minikube -p tbw'
alias mktl='minikube -p tbw service list'
alias h=helm

# alias & func
whoseport () {
   lsof -i ":$1" | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn} LISTEN
}

alias nview='nvim -R'

alias ag="ag --color-path '1;34' --color-line-number '0;37' --color-match '0;32' --color --break --group --heading"

alias mocp="mocp -T green_theme"
