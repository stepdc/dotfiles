# Setup fzf
# ---------
if [[ ! "$PATH" == */home/ricd/.fzf/bin* ]]; then
  export PATH="$PATH:/home/ricd/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/ricd/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/ricd/.fzf/shell/key-bindings.bash"

