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
