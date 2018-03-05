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

if [[ -s "$HOME/.dot/yadm" ]]; then
  fpath=($HOME/.dot/yadm $fpath)
  autoload -U compinit
  compinit
fi
  
