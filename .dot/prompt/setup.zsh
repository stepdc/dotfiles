# see https://github.com/sindresorhus/pure/blob/master/pure.zsh

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


prompt_stepdc_async_vcs_info() {
	setopt localoptions noshwordsplit

	# configure vcs_info inside async task, this frees up vcs_info
	# to be used or configured as the user pleases.
	zstyle ':vcs_info:*' enable git
	zstyle ':vcs_info:*' use-simple true
	# only export two msg variables from vcs_info
	zstyle ':vcs_info:*' max-exports 2
	# export branch (%b) and git toplevel (%R)
	zstyle ':vcs_info:git*' formats '%b' '%R'
	zstyle ':vcs_info:git*' actionformats '%b|%a' '%R'

	vcs_info

	local -A info
	info[pwd]=$PWD
	info[top]=$vcs_info_msg_1_
	info[branch]=$vcs_info_msg_0_

	print -r - ${(@kvq)info}
}

# fastest possible way to check if repo is dirty
prompt_stepdc_async_git_dirty() {
	setopt localoptions noshwordsplit
	local untracked_dirty=$1

	if [[ $untracked_dirty = 0 ]]; then
		command git diff --no-ext-diff --quiet --exit-code
	else
		test -z "$(command git status --porcelain --ignore-submodules -unormal)"
	fi

	return $?
}

prompt_stepdc_human_time_to_var() {
    local human total_seconds=$1 var=$2
    local days=$(( total_seconds / 60 / 60 / 24 ))
    local hours=$(( total_seconds / 60 / 60 % 24 ))
    local minutes=$(( total_seconds / 60 % 60 ))
    local seconds=$(( total_seconds % 60 ))
    (( days > 0 )) && human+="${days}d "
    (( hours > 0 )) && human+="${hours}h "
    (( minutes > 0 )) && human+="${minutes}m "
    human+="${seconds}s"

    # store human readable time in variable as specified by caller
    typeset -g "${var}"="${human}"
}

prompt_stepdc_check_cmd_exec_time() {
    integer elapsed
    (( elapsed = EPOCHSECONDS - ${prompt_stepdc_cmd_timestamp:-$EPOCHSECONDS} ))
    typeset -g prompt_stepdc_cmd_exec_time=
    (( elapsed > ${STEPDC_CMD_MAX_EXEC_TIME:-2} )) && {
            prompt_stepdc_human_time_to_var $elapsed "prompt_stepdc_cmd_exec_time"
    }
}

if [[ ! -a ~/.zsh-async ]]; then
  git clone -b 'v1.7.1' git@github.com:mafredri/zsh-async ~/.zsh-async
fi
source ~/.zsh-async/async.zsh

# Initialize zsh-async
async_init

function prompt_stepdc_async_tasks {
    setopt localoptions noshwordsplit

    if (( !${prompt_stepdc_async_init:-0} )); then
	async_start_worker prompt_stepdc -n
	async_register_callback prompt_stepdc prompt_stepdc_async_callback
	typeset -g prompt_stepdc_async_init=1
    fi

    # Update the current working directory of the async worker.
    async_worker_eval "prompt_stepdc" builtin cd -q $PWD

    typeset -gA prompt_stepdc_vcs_info

    local -H MATCH MBEGIN MEND
    if [[ $PWD != ${prompt_stepdc_vcs_info[pwd]}* ]]; then
            # stop any running async jobs
            async_flush_jobs "prompt_stepdc"

            # reset git preprompt variables, switching working tree
            unset prompt_stepdc_git_dirty
            unset prompt_stepdc_git_last_dirty_check_timestamp
            prompt_stepdc_vcs_info[branch]=
            prompt_stepdc_vcs_info[top]=
    fi
    unset MATCH MBEGIN MEND

    async_job "prompt_stepdc" prompt_stepdc_async_vcs_info

    # only perform tasks inside git working tree
    [[ -n $prompt_stepdc_vcs_info[top] ]] || return

    prompt_stepdc_async_refresh
}

prompt_stepdc_async_refresh() {
    setopt localoptions noshwordsplit

    # if dirty checking is sufficiently fast, tell worker to check it again, or wait for timeout
    integer time_since_last_dirty_check=$(( EPOCHSECONDS - ${prompt_stepdc_git_last_dirty_check_timestamp:-0} ))
    if (( time_since_last_dirty_check > ${STEPDC_GIT_DELAY_DIRTY_CHECK:-1800} )); then
            unset prompt_stepdc_git_last_dirty_check_timestamp
            # check check if there is anything to pull
            async_job "prompt_stepdc" prompt_stepdc_async_git_dirty ${STEPDC_GIT_UNTRACKED_DIRTY:-1}
    fi
}

function prompt_stepdc_preexec {
    typeset -g prompt_stepdc_cmd_timestamp=$EPOCHSECONDS
}


function prompt_stepdc_preprompt_render() {
    setopt localoptions noshwordsplit

    _prompt_stepdc_pwd=`_short_prompt_pwd`

    # Set color for git branch/dirty status, change color if dirty checking has
    # been delayed.
    local git_color=242
    [[ -n ${prompt_stepdc_git_last_dirty_check_timestamp+x} ]] && git_color=red

    # Initialize the preprompt array.
    local -a rprompt_parts

    [[ -n $prompt_stepdc_cmd_exec_time ]] && rprompt_parts+=('%F{yellow}${prompt_stepdc_cmd_exec_time}%f')


    # Add git branch and dirty status info.
    typeset -gA prompt_stepdc_vcs_info
    if [[ -n $prompt_stepdc_vcs_info[branch] ]]; then
        rprompt_parts+=("%F{$git_color}"'${prompt_stepdc_vcs_info[branch]}${prompt_stepdc_git_dirty}')
    fi

    PROMPT='%F{2}${_prompt_stepdc_pwd}%f » '
    RPROMPT="${(j. .)rprompt_parts}"

    local -ah ps1
    ps1=(
        $PROMPT
        $RPROMPT
    )
    TOTALPROMPT="${(j..)ps1}"

    local expanded_prompt
    expanded_prompt="${(S%%)TOTALPROMPT}"

    if [[ $1 == precmd ]]; then
            ;
    elif [[ $prompt_stepdc_last_prompt != $expanded_prompt ]]; then
        zle && zle .reset-prompt
    fi

    typeset -g prompt_stepdc_last_prompt=$expanded_prompt
}

function prompt_stepdc_precmd {
    # check exec time and store it in a variable
    prompt_stepdc_check_cmd_exec_time
    unset prompt_stepdc_cmd_timestamp

    prompt_stepdc_async_tasks

    prompt_stepdc_preprompt_render "precmd"
}

function prompt_stepdc_async_callback {
    setopt localoptions noshwordsplit
    local job=$1 code=$2 output=$3 exec_time=$4 next_pending=$6
    local do_render=0

    case $job in
            \[async])
		# code is 1 for corrupted worker output and 2 for dead worker
		if [[ $code -eq 2 ]]; then
		    # our worker died unexpectedly
		    typeset -g prompt_stepdc_async_init=0
                fi
                ;;
        prompt_stepdc_async_vcs_info)
                local -A info
                typeset -gA prompt_stepdc_vcs_info

                # parse output (z) and unquote as array (Q@)
		info=("${(Q@)${(z)output}}")
		local -H MATCH MBEGIN MEND
                if [[ $info[pwd] != $PWD ]]; then
                    # The path has changed since the check started, abort.
                    return
                fi
		# check if git toplevel has changed
                if [[ $info[top] = $prompt_stepdc_vcs_info[top] ]]; then
                    # if stored pwd is part of $PWD, $PWD is shorter and likelier
                    # to be toplevel, so we update pwd
                    if [[ $prompt_stepdc_vcs_info[pwd] = ${PWD}* ]]; then
                       prompt_stepdc_vcs_info[pwd]=$PWD
                    fi
                else
		    # store $PWD to detect if we (maybe) left the git path
                            prompt_stepdc_vcs_info[pwd]=$PWD
                fi
                unset MATCH MBEGIN MEND

		# update has a git toplevel set which means we just entered a new
		# git directory, run the async refresh tasks
		[[ -n $info[top] ]] && [[ -z $prompt_stepdc_vcs_info[top] ]] && prompt_stepdc_async_refresh

		# always update branch and toplevel
		prompt_stepdc_vcs_info[branch]=$info[branch]
		prompt_stepdc_vcs_info[top]=$info[top]

		do_render=1
                ;;
        prompt_stepdc_async_git_dirty)
                local prev_dirty=$prompt_stepdc_git_dirty
                if (( code == 0 )); then
                    unset prompt_stepdc_git_dirty
                else
                    typeset -g prompt_stepdc_git_dirty="*"
                fi

                [[ $prev_dirty != $prompt_stepdc_git_dirty ]] && do_render=1

		# When prompt_pure_git_last_dirty_check_timestamp is set, the git info is displayed in a different color.
		# To distinguish between a "fresh" and a "cached" result, the preprompt is rendered before setting this
		# variable. Thus, only upon next rendering of the preprompt will the result appear in a different color.
		(( $exec_time > 5 )) && prompt_stepdc_git_last_dirty_check_timestamp=$EPOCHSECONDS
                ;;
    esac

    if (( next_pending )); then
        (( do_render )) && typeset -g prompt_stepdc_async_render_requested=1
        return
    fi

    [[ ${prompt_stepdc_async_render_requested:-$do_render} = 1 ]] && prompt_stepdc_preprompt_render
    unset prompt_stepdc_async_render_requested
}

function prompt_stepdc_setup {
    setopt LOCAL_OPTIONS
    unsetopt XTRACE KSH_ARRAYS
    prompt_opts=(cr percent sp subst)

    # borrowed from promptinit, sets the prompt options in case pure was no
    # initialized via promptinit.
    setopt noprompt{bang,cr,percent,subst} "prompt${^prompt_opts[@]}"

    if [[ -z $prompt_newline ]]; then
	# This variable needs to be set, usually set by promptinit.
	typeset -g prompt_newline=$'\n%{\r%}'
    fi

    zmodload zsh/datetime
    zmodload zsh/zle
    zmodload zsh/parameter

    autoload -Uz add-zsh-hook
    autoload -Uz async && async
    autoload -Uz vcs_info

    add-zsh-hook precmd prompt_stepdc_precmd
    add-zsh-hook preexec prompt_stepdc_preexec

    # prompt_stepdc_state_setup, ssh related, do it later...

    # setup return value later

    # setup async worker
    _stepdc_cur_git_root=''

    _prompt_stepdc_pwd=''
    _prompt_stepdc_git_branch=''

    # PROMPT='%f%n@%m %F{2}${_prompt_stepdc_pwd}%f> '
    PROMPT='%F{2}${_prompt_stepdc_pwd}%f » '
    # RPROMPT="%F{"167"}`prompt_stepdc_cmd_exec_time`${_prompt_stepdc_git_branch}"
}

prompt_stepdc_setup
