function _fish_collapsed_pwd() {
    local pwd="$1"
    local home="$HOME"
    local size=${#home}
    [[ $# == 0 ]] && pwd="$PWD"
    [[ -z "$pwd" ]] && return
    if [[ "$pwd" == "/" ]]; then
        echo "/"
        return
    elif [[ "$pwd" == "$home" ]]; then
        echo "~"
        return
    fi
    [[ "$pwd" == "$home/"* ]] && pwd="~${pwd:$size}"
    if [[ -n "$BASH_VERSION" ]]; then
        local IFS="/"
        local elements=($pwd)
        local length=${#elements[@]}
        for ((i=0;i<length-1;i++)); do
            local elem=${elements[$i]}
            if [[ ${#elem} -gt 1 ]]; then
                if [[ ${elem:0:1} == "." ]]; then
                    elements[$i]=${elem:0:2}
                else
                    elements[$i]=${elem:0:1}
                fi
            fi
        done
    else
        local elements=("${(s:/:)pwd}")
        local length=${#elements}
        for i in {1..$((length-1))}; do
            local elem=${elements[$i]}
            if [[ ${#elem} > 1 ]]; then
                if [[ ${elem[1]} == "." ]]; then
                    elements[$i]=${elem[1,2]}
                else
                    elements[$i]=${elem[1]}
                fi
            fi
        done
    fi
    local IFS="/"
    echo "${elements[*]}"
}

if [ -n "$BASH_VERSION" ]; then
    if [ "$UID" -eq 0 ]; then
        export PS1='\u@\h \[\e[31m\]$(_fish_collapsed_pwd)\[\e[0m\]# '
    else
        export PS1='\u@\h \[\e[32m\]$(_fish_collapsed_pwd)\[\e[0m\]> '
    fi
else
    if [ $UID -eq 0 ]; then
        export PROMPT='%f%n@%m %F{1}$(_fish_collapsed_pwd)%f# '
    else
        export PROMPT='%f%n@%m %F{2}$(_fish_collapsed_pwd)%f> '
    fi
fi


# turns seconds into human readable time, 165392 => 1d 21h 56m 32s
prompt_human_time() {
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


prompt_cmd_exec_time() {
    local stop=$EPOCHSECONDS
    local start=${cmd_timestamp:-$stop}
    integer elapsed=$stop-$start
    (($elapsed > ${PROMPT_CMD_MAX_EXEC_TIME:=1})) && prompt_human_time $elapsed
}

prompt_preexec() {
    cmd_timestamp=$EPOCHSECONDS
}



prompt_precmd() {
    export RPROMPT="%F{"244"}`prompt_cmd_exec_time`"
    unset cmd_timestamp # reset value since `preexec` isn't always triggered
}

prompt_setup() {
    zmodload zsh/datetime
    autoload -Uz add-zsh-hook

    add-zsh-hook precmd prompt_precmd
    add-zsh-hook preexec prompt_preexec
}

prompt_setup
