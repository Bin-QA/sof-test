#!/bin/bash

# using aliases to cover log defines --- more like C log functions
_func_log_cmd()
{
    # the local & remote are different:
    # the local is login
    # the remote is running the commands
    # for example:
    #     remote: ssh xxx@xxx cmd
    #     local: ssh xxx@xxx
    #           $ cmd
    # We can use the system's private environment to know whether this script is
    # run from local or remote
    # Notice: this command only verified on Ubuntu
    local key __LOG_PREFIX=""
    local -A LOG_LIST

    [[ ! "$LS_COLORS" ]] && __LOG_PREFIX="REMOTE_"

    LOG_LIST['dlogi']="[$__LOG_PREFIX""INFO]"
    LOG_LIST['dloge']="[$__LOG_PREFIX""ERROR]"
    LOG_LIST['dlogc']="[$__LOG_PREFIX""COMMAND]"
    LOG_LIST['dlogw']="[$__LOG_PREFIX""WARNING]"

    # open aliases for script, so it can use the dlogx commands instead of
    # writing functions
    shopt -s expand_aliases
    # PPID: The process ID of the shell's parent.
    # get current script parent process name
    local ppcmd
    ppcmd=$(ps -p $PPID -o cmd --noheader|awk '{print $2;}')
    local ext_message=""
    # confirm this is loaded by the script, and add the flag for it
    file "$ppcmd" 2>/dev/null |grep -q 'shell script' && ext_message=" Sub-Test:"
    for key in "${!LOG_LIST[@]}";
    do
        # dymaic alias the command with different content
        # shellcheck disable=SC2139
        alias "$key=echo \$(date -u \"+%F %T %Z\")$ext_message ${LOG_LIST[$key]}"
    done
}

# without setting up the LOG_ROOT keyword, now create the log directory for it
_func_log_directory()
{
    if [ "$LOG_ROOT" ]; then
        mkdir -p "$LOG_ROOT"
        return
    fi

    local case_name log_dir timetag
    case_name=$(basename "${BASH_SOURCE[-1]}")
    case_name=${case_name%.*}
    log_dir=$SCRIPT_HOME/logs/$case_name
    timetag=$(date +%F"-"%T)"-$RANDOM"
    mkdir -p "$log_dir/$timetag"
    # now using the last link for the time tag
    [[ -L $log_dir/last ]] && rm "$log_dir"/last
    if [[ ! -e $log_dir/last ]]; then
        ln -s "$log_dir/$timetag" "$log_dir"/last
    fi
    export LOG_ROOT=$log_dir/$timetag
}

for _func_ in $(declare -F|grep _func_log_|awk '{print $NF;}')
do
    $_func_
    eval "unset $_func_"
done
unset _func_
