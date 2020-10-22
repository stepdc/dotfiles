# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls --group-directories-first --color=auto'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

[[ $HOME/.dot/shconfig ]] && source $HOME/.dot/shconfig

bind 'set completion-ignore-case on'
bind "TAB:menu-complete"
bind "set show-all-if-ambiguous on"
bind "set menu-complete-display-prefix on"

# ignore duplicated history
export HISTCONTROL=ignoredups
