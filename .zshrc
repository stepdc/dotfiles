#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

[[ $HOME/.dot/shconfig ]] && source $HOME/.dot/shconfig
[[ $HOME/.dot/fzf.zsh ]] && source $HOME/.dot/fzf.zsh

# autojump
[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && \
  source $HOME/.autojump/etc/profile.d/autojump.sh

# fpath should copy to /etc/zshrc manually, 0.5s startup time shrink
# if [[ -s "$HOME/.dot/yadm" ]]; then
#   fpath=($HOME/.dot/yadm $fpath)
# fi
#
# if [[ -s "$HOME/.cht.sh" ]]; then
#   fpath=($HOME/.cht.sh $fpath)
# fi

# autoload -U compinit && compinit -u

export TERM=xterm-256color

# history
# HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
# setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
# setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
# setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
# setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.
