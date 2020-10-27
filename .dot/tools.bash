# prompt
[ -s $HOME/.dot/prompt/setup.bash ] && source $HOME/.dot/prompt/setup.bash

# fzf
[ -f $HOME/.fzf.bash ] && source $HOME/.fzf.bash
function zz() {
        local dir
        dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "$dir" || return 1
}

export LS_OPTIONS='--color=auto'

# z.lua
[ -s $HOME/.dot/repos/z.lua ] && eval "$(lua $HOME/.dot/repos/z.lua/z.lua \
        --init bash enhanced once)"

# misc
# make bash feel like zsh
bind 'set completion-ignore-case on'
bind "TAB:menu-complete"
bind "set show-all-if-ambiguous on"
bind "set menu-complete-display-prefix on"
stty werase undef
bind '\C-w:unix-filename-rubout'

# ignore duplicated history
export HISTCONTROL=ignoredups
