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

alias cs1='ssh -A -t zhangbo@10.0.0.1 ssh -A -t zhangbo01@10.20.34.27 -A -t qssh root@cs1'
alias jjh='ssh -A -t zhangbo@10.0.0.1 ssh -A -t zhangbo01@10.20.34.27'
alias ag="ag --color-path '1;34' --color-line-number '0;37' --color-match '0;32' --color --break --group --heading"
