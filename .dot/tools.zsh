# repos
# z.lua
# setup z.lua
function _stepdc_setup_zlua() {
        #bindkey '^j' _stepdc_recent_paths
        bindkey -s '^j' '_zlua -I -t .^M' # recent files
        bindkey -s '^x^f' '_zlua -I -c .^M' # cd subdir
        bindkey -s '^xf' '_zlua -I -c .^M'
}

if [[ ! -a $HOME/.dot/repos/z.lua ]]; then
  git clone -b 'v1.8.7' https://github.com/skywind3000/z.lua.git $HOME/.dot/repos/z.lua
fi
[[ -s $HOME/.dot/repos/z.lua/z.lua.plugin.zsh ]] && \
        eval "$(lua $HOME/.dot/repos/z.lua/z.lua --init zsh enhanced once fzf)" && \
        _stepdc_setup_zlua

if [[ ! -a $HOME/.dot/repos/zsh-async ]]; then
  git clone -b 'v1.8.5' https://github.com/mafredri/zsh-async.git $HOME/.dot/repos/zsh-async
fi
[[ -s $HOME/.dot/repos/zsh-async ]] && \
        source $HOME/.dot/repos/zsh-async/async.zsh && async_init

# async prompt
[ -n "$ZSH_VERSION" ] && [ -s $HOME/.dot/prompt/setup.zsh ] && source $HOME/.dot/prompt/setup.zsh

# title
function precmd () {
  window_title="\033]0;`_short_prompt_pwd`\007"
  echo -ne "$window_title"
}

# Update terminal/tmux window titles based on location/command

# function update_title() {
#         local a
#         # escape '%' in $1, make nonprintables visible
#         a=${(V)1//\%/\%\%}
#         print -nz "%20>...>$a"
#         read -rz a
#         # remove newlines
#         a=${a//$'\n'/}
#         if [[ -n "$TMUX" ]] && [[ $TERM == screen* || $TERM == tmux* ]]; then
#                 print -n "\ek${(%)a}:${(%)2}\e\\"
#         elif [[ "$TERM" =~ "screen*" ]]; then
#                 print -n "\ek${(%)a}:${(%)2}\e\\"
#         elif [[ "$TERM" =~ "xterm*" || "$TERM" = "alacritty" || "$TERM" =~ "st*" ]]; then
#                 print -n "\e]0;${(%)a}:${(%)2}\a"
#         elif [[ "$TERM" =~ "^rxvt-unicode.*" ]]; then
#                 printf '\33]2;%s:%s\007' ${(%)a} ${(%)2}
#         fi
# }
#
# # called just before the prompt is printed
# function _zsh_title__precmd() {
#         update_title "zsh" "%20<...<%~"
# }
#
# # called just before a command is executed
# function _zsh_title__preexec() {
#   local -a cmd
#
#   # Escape '\'
#   1=${1//\\/\\\\\\\\}
#
#   cmd=(${(z)1})             # Re-parse the command line
#
#   # Construct a command that will output the desired job number.
#   case $cmd[1] in
#     fg)	cmd="${(z)jobtexts[${(Q)cmd[2]:-%+}]}" ;;
#     %*)	cmd="${(z)jobtexts[${(Q)cmd[1]:-%+}]}" ;;
#   esac
#   update_title "$cmd" "%20<...<%~"
# }

# autoload -Uz add-zsh-hook
# add-zsh-hook precmd _zsh_title__precmd
# add-zsh-hook preexec _zsh_title__preexec

# fzf
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
function zz() {
        local dir
        dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "$dir" || return 1
}

# [[ -s $HOME/.dot/zsh_completion.d/_minikube ]] && \
#         source $HOME/.dot/zsh_completion.d/_minikube
