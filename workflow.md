- [automation script format](#automation-script-format)
  - [case description](#case-description)
  - [source bash lib](#source-bash-lib)
  - [case option](#case-option)
  - [case result](#case-result)
- [Common workflow](#common-workflow)
  - [source step](#source-step)
  - [hijack step](#hijack-step)
  - [case step](#case-step)

# automation script format
## case description
`##` mark case description information which will dump when load case with -h option
## source bash lib
using oneline `source $(dirname ${BASH_SOURCE[0]})/../case-lib/lib.sh` to include all bash help function
## case option
Base on `declare -A` of bash and `getopt` command to create `OPT_*_lst` to help create option function  
Notice `getopt` is different with `getopts` of bash
## case result
Case exit code decide Case result

# Common workflow
Bash script language is linear
## source step
1. [source all lib script](case-lib/lib.sh#L3)
2. [load configure](case-lib/config.sh)
   presetup configure refer the environment setup
3. [load option lib](case-lib/opt.sh)
   Test Case can support custom option
   `func_opt_parse_option`
4. [load log refer lib](case-lib/logging_ctl.sh)
   support `dlog*` command
   create `LOG_ROOT` to store log
5. [load pipline lib](case-lib/pipeline.sh)
   base on `sof-tplgreader.py` to support convert TPLG to Bash Array
6. [load hijack lib](case-lib/hijack.sh)
   hijack `exit` and `sudo` command
7. `export PATH` to add `tools` into `PATH`
8. Detect `SOFCARD`
9.  ~~ detect lock file:`SOF_LOCK` ~~
10. record kernel log line: `DMESG_LOG_START_LINE`
11. register function:
    1.  `func_lib_setup_kernel_last_line` use to check /var/log/kernel.log last line almost to use at sof-kernel-log-check.sh
    2.  `func_lib_start_log_collect` open control for the aplay/arecord like function
    3.  `func_lib_check_sudo`  will just load once, when you load 'sudo' it will loaded `func_hijack_setup_sudo_level` mapping
    4.  `func_lib_disable_pulseaudio` disable pulseaudio
    5.  `func_lib_restore_pulseaudio` enable pulseaudio
    6.  `func_lib_get_random`
    7.  `func_lib_lsof_error_dump` use to dump target file process
## hijack step
1. `exit`
   1. check log_collect whether is open `func_lib_start_log_collect` mapping action
   2. collect kernel message information
   3. check whether have the child process
   4. try to enable pulseaudio `func_lib_restore_pulseaudio`
   5. ~~ remove `SOF_LOCK` ~~
   6. dump case result information
2. `sudo`
   1. `func_hijack_setup_sudo_level` check sudo command: this behivor for community
   2. apply sudo command for different sudo type
## case step
1. custom option to get parameter
2. do the environment check
3. do the test step
4. exit with exit code
