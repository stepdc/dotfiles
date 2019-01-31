function _short_prompt_pwd {
    setopt localoptions extendedglob
    local current_pwd="${PWD/#$HOME/~}"
    local ret_directory

    if [[ "$current_pwd" == (#m)[/~] ]]; then
        ret_directory="$MATCH"
        unset MATCH
    else
        ret_directory="${${${${(@j:/:M)${(@s:/:)current_pwd}##.#?}:h}%/}//\%/%%}/${${current_pwd:t}//\%/%%}"
    fi
    unset current_pwd
    print "$ret_directory"
}

function git-dir {
    local git_dir="${$(command git rev-parse --git-dir):A}"

    if [[ -n "$git_dir" ]]; then
	print "$git_dir"
	return 0
    else
	print "$0: not a repository: $PWD" >&2
	return 1
    fi
}

if [ -n "$BASH_VERSION" ]; then
    if [ "$UID" -eq 0 ]; then
        export PS1='\u@\h \[\e[31m\]$(_short_prompt_pwd)\[\e[0m\]# '
    else
        export PS1='\u@\h \[\e[32m\]$(_short_prompt_pwd)\[\e[0m\]> '
    fi
else
    if [ $UID -eq 0 ]; then
        export PROMPT='%f%n@%m %F{1}$(_short_prompt_pwd)%f# '
    else
        export PROMPT='%f%n@%m %F{2}$(_short_prompt_pwd)%f> '
    fi
fi

_stepdc_branch_status() {
    cd -q $1
    
    local ref branch
    ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
    case $? in        # See what the exit code is.
	0) ;;           # $ref contains the name of a checked-out branch.
	128) return ;;  # No Git repository here.
	# Otherwise, see if HEAD is in detached state.
	*) ref=$(command git rev-parse --short HEAD 2> /dev/null) || return ;;
    esac
    branch=${ref#refs/heads/}

    if [[ -n $branch ]]; then
	local git_status symbols k
	git_status="$(LC_ALL=C command git status 2>&1)"

	typeset -A messages
	messages=(
	    '&*'  'diverged'
	    '&'   'behind'
	    '*'   'Your branch is ahead of'
	    '+'   'new file:'
	    'x'   'deleted'
	    '!'   'modified:'
	    '>'   'renamed:'
	    '?'   'Untracked files'
	)

	for k in '&*' '&' '*' '+' 'x' '!' '>' '?'; do
	    case $git_status in
		*${messages[$k]}*) symbols+="$k" ;;
	    esac
	done

	[[ -n $symbols ]] && symbols=" ${symbols}"

	printf ' (%s%s)' "$branch" "$symbols"
    fi
}

prompt_stepdc_git_dirty() {
    cd -q "$1"

    # check if we're in a git repo
    command git rev-parse --is-inside-work-tree &>/dev/null || return
    # check if it's dirty
    local umode="-uno" #|| local umode="-unormal"
    command test -n "$(git status --porcelain --ignore-submodules ${umode} 2>/dev/null | head -100)"

    return $?
}


# turns seconds into human readable time, 165392 => 1d 21h 56m 32s
prompt_stepdc_human_time() {
    local tmp=$1
    local days=$(( tmp / 60 / 60 / 24 ))
    local hours=$(( tmp / 60 / 60 % 24 ))
    local minutes=$(( tmp / 60 % 60 ))
    local seconds=$(( tmp % 60 ))
    (( $days > 0 )) && echo -n "${days}d "
    (( $hours > 0 )) && echo -n "${hours}h "
    (( $minutes > 0 )) && echo -n "${minutes}m "
    echo "${seconds}s "
}


prompt_stepdc_cmd_exec_time() {
    local stop=$EPOCHSECONDS
    local start=${cmd_timestamp:-$stop}
    integer elapsed=$stop-$start
    (($elapsed > ${PROMPT_CMD_MAX_EXEC_TIME:=1})) && prompt_human_time $elapsed
}

if [[ ! -a ~/.zsh-async ]]; then
  git clone -b 'v1.7.1' git@github.com:mafredri/zsh-async ~/.zsh-async
fi
source ~/.zsh-async/async.zsh

# Initialize zsh-async
async_init

function prompt_stepdc_async_callback {
    case $1 in
        prompt_stepdc_async_git)
	    if (( $2 == 0 )); then
		_prompt_stepdc_git_branch=$3
	    else
		if [[ -n "$_prompt_stepdc_git_branch" ]]; then
		    _prompt_stepdc_git_branch=''
		fi
	    fi
	    zle && zle reset-prompt

	    ;;
    esac
}

function prompt_stepdc_async_git {
    # git_pwd="$1"
    # cd -q "$git_pwd"

    # local dirty_mark=''
    # prompt_stepdc_git_dirty "$git_pwd"
    # if (( $? == 0 )); then
    # 	dirty_mark=' +'
    # fi

    # vcs_info
    # print "$vcs_info_msg_0_$dirty_mark"
    print "`_stepdc_branch_status $1`"
}

function prompt_stepdc_async_tasks {
    if (( !${prompt_stepdc_async_init:-0} )); then
	async_start_worker prompt_stepdc -n
	async_register_callback prompt_stepdc prompt_stepdc_async_callback
	typeset -g prompt_stepdc_async_init=1
    fi

    # Kill the old process of slow commands if it is still running.
    async_flush_jobs prompt_stepdc

    # Compute slow commands in the background.
    async_job prompt_stepdc prompt_stepdc_async_git "$PWD"
}

function prompt_stepdc_precmd {
    setopt LOCAL_OPTIONS
    unsetopt XTRACE KSH_ARRAYS

    _prompt_stepdc_pwd=`_short_prompt_pwd`

    # Handle updating git data. We also clear the git prompt data if we're in a
    # different git root now.
    if (( $+functions[git-dir] )); then
	local new_git_root="$(git-dir 2> /dev/null)"
	if [[ $new_git_root != $_stepdc_cur_git_root ]]; then
	    _prompt_stepdc_git_branch=''
	    _stepdc_cur_git_root=$new_git_root
	fi
    fi

    setopt localoptions noshwordsplit
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git*' formats ' %b'
    zstyle ':vcs_info:git*' actionformats ' %b|%a'

    prompt_stepdc_async_tasks

    RPROMPT="%F{"167"}${_prompt_stepdc_git_branch}"
}

function prompt_stepdc_setup {
    setopt LOCAL_OPTIONS
    unsetopt XTRACE KSH_ARRAYS
    prompt_opts=(cr percent sp subst)

    autoload -Uz add-zsh-hook
    autoload -Uz async && async
    autoload -Uz vcs_info

    add-zsh-hook precmd prompt_stepdc_precmd

    # setup return value later

    # setup async worker
    _stepdc_cur_git_root=''
    
    _prompt_stepdc_pwd=''
    _prompt_stepdc_git_branch=''

    PROMPT='%f%n@%m %F{2}${_prompt_stepdc_pwd}%f> '
}

prompt_stepdc_setup
