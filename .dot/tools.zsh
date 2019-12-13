# repos
# z.lua
if [[ ! -a $HOME/.dot/repos/z.lua ]]; then
  git clone -b 'v1.7.3' https://github.com/skywind3000/z.lua.git $HOME/.dot/repos/z.lua
fi
[[ -s $HOME/.dot/repos/z.lua/z.lua.plugin.zsh ]] && \
        eval "$(lua $HOME/.dot/repos/z.lua/z.lua --init zsh enhanced once fzf)"

# async prompt
[ -n "$ZSH_VERSION" ] && [ -s $HOME/.dot/prompt/setup.zsh ] && source $HOME/.dot/prompt/setup.zsh

# fzf
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
function zz() {
        local dir
        dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "$dir" || return 1
}

[[ -s $HOME/.dot/zsh_completion.d/_minikube ]] && \
        source $HOME/.dot/zsh_completion.d/_minikube

