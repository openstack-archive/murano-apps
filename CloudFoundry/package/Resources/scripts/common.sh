#!/bin/bash
#  Licensed under the Apache License, Version 2.0 (the "License"); you may
#  not use this file except in compliance with the License. You may obtain
#  a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#  License for the specific language governing permissions and limitations
#  under the License.

DEBUGLVL=3
LOGFILE=/tmp/muranodeployment.log
PIPAPPS="pip python-pip pip-python"
PIPCMD=""
if [ "$DEBUGLVL" -eq 4 ]; then
    set -x
fi
function log {
    if [ "$DEBUGLVL" -gt 0 ]; then
        chars=$(echo "@$" | wc -c)
        echo "Parsed chars: ${chars}"
        case $DEBUGLVL in
            1 )
                echo -e "LOG:>$@"
                ;;
            2)
                echo -e "$(date +"%m-%d-%Y %H:%M") LOG:>$@" | tee --append $LOGFILE
                ;;
            3)
                echo -e "$(date +"%m-%d-%Y %H:%M") LOG:>$@" >> $LOGFILE
                ;;
            4)
                echo -e "$(date +"%m-%d-%Y %H:%M") LOG:>$@" | tee --append $LOGFILE
                ;;
        esac
    fi
}
function lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}
function find_pip()
{
    for cmd in $PIPAPPS
    do
        _cmd=$(which "$cmd" 2>/dev/null)
        if [ $? -eq 0 ];then
                break
        fi
    done
    if [[ -z $_cmd ]];then
        echo "Can't find \"pip\" in system, please install it first, exiting!"
        exit 1
    else
        export PIPCMD=$_cmd
    fi
}
OPTIND=1 # Reset if getopts used previously
function collect_args(){
    _n=$1
    shift
    ARGS=''
    while true
    do
        if [[ "$_n" == -* ]] || [ -z "$_n" ]; then
            OPTIND=$((OPTIND - 1))
            break
        fi
        #echo "_n=$_n ; $OPTIND"
        if [ -z "$ARGS" ]; then
            ARGS=$OPTARG
        else
            ARGS="$ARGS $_n"
        fi
        eval _n=\$$OPTIND
        OPTIND=$((OPTIND + 1))
        #sleep 1
    done
    echo "${ARGS}"
    unset _n
    unset ARGS
}
function get_os(){
    # (azvyagintsev) export variables just for clearing shellcheck warning's
    export KERNEL=$(uname -r)
    export MACH=$(uname -m)
    export OS=$(uname)
    if [ "${OS}" = "Linux" ] ; then
        if [ -f /etc/redhat-release ] ; then
            export DistroBasedOn='RedHat'
            export Packager='yum'
            export DIST=$(< /etc/redhat-release sed s/\ release.*// )
            export PSUEDONAME=$(< /etc/redhat-release sed -e s/.*\(// -e s/\)// )
            export REV=$(< /etc/redhat-release sed -e s/.*release\ // -e s/\ .*//)
        elif [ -f /etc/SuSE-release ] ; then
            export DistroBasedOn='SuSe'
            export Packager='zypper'
            export PSUEDONAME=$(< /etc/SuSE-release tr "\n" ' '| sed s/VERSION.*//)
            export REV=$(< /etc/SuSE-release tr "\n" ' ' | sed s/.*=\ //)
        elif [ -f /etc/mandrake-release ] ; then
            export DistroBasedOn='Mandrake'
            export Packager='urpmi urpme'
            export PSUEDONAME=$(< /etc/mandrake-release sed s/.*\(// | sed s/\)//)
            export REV=$(< /etc/mandrake-release sed s/.*release\ // | sed s/\ .*//)
        elif [ -f /etc/debian_version ] ; then
            export DistroBasedOn='Debian'
            export Packager='apt-get'
            export DIST=$(< /etc/lsb-release grep '^DISTRIB_ID' | awk -F=  '{ print $2 }')
            export PSUEDONAME=$(< /etc/lsb-release grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }')
            export REV=$(< /etc/lsb-release grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }')
        fi
        if [ -f /etc/UnitedLinux-release ] ; then
            DIST="${DIST}[$(< /etc/UnitedLinux-release tr "\n" ' ' | sed s/VERSION.*//)]"
        fi
        OS=$(lowercase "$OS")
        DistroBasedOn=$(lowercase "$DistroBasedOn")
        readonly OS
        readonly DIST
        readonly DistroBasedOn
        readonly PSUEDONAME
        readonly REV
        readonly KERNEL
        readonly MACH
        #readonly Packager
    else
        OS=unknown
        readonly OS
        log "OS:$OS"
        exit 1
    fi
}
function add_fw_rule(){
    _rule_string=$*
    _tmp_fw_port=$(echo "$_rule_string" | grep -o -e "dport [0-9]*\s")
    _tmp_fw_proto=$(echo "$_rule_string" | grep -o -e "-p \w*\s")
    _fw_port=$(echo "$_tmp_fw_port" | awk '{print $2}')
    _fw_proto=$(echo "$_tmp_fw_proto" |awk '{print $2}')
    _fw_reload=""
    # (azvyagintsev) Do echo just for remove shellcheck warning
    echo "${_fw_reload}" >> /dev/null
    #find iptables and add rule
    case "$DIST" in
        "Fedora")
            _fw_cmd=$(which firewall-cmd)
            _fw_port=$(echo "$_rule_string" | grep -o -e "dport [0-9]*\s" | awk '{print $2}')
            _fw_proto=$(echo "$_rule_string" | grep -o -e "-p \w*\s" | awk '{print $2}')
            _fw_rule="--permanent --add-port=$_fw_port/$_fw_proto"
            _fw_enable_rules="$_fw_cmd --reload"
            ;;
        *)
            _fw_cmd=$(which iptables)
            _fw_rule=$_rule_string
            _fw_enable_rules="service $(basename "$_fw_cmd") save"
            ;;
    esac
    iptcmdsave=$(which iptables-save)
    if [[ "$_fw_cmd" != '' ]] && [[ "$iptcmdsave" != '' ]]; then
        eval "$iptcmdsave | grep -e \"$_tmp_fw_port\" | grep -e \"$_tmp_fw_proto\"" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            eval "$_fw_cmd $_fw_rule"
            if [ $? -ne 0 ]; then
                log "Can't set firewall rules, exiting..."
                exit 1
            else
                if [ -n "$_fw_enable_rules" ]; then
                    log "Running \"$_fw_enable_rules\""
                    $_fw_enable_rules > /dev/null
                fi
                log "$_fw_cmd rule with $_fw_rule set."
            fi
        else
            log "$_fw_cmd rule exists."
        fi
    else
        log "There are no fw found..."
    fi
}
function enable_init(){
    _initctrl=""
    _init_suffix=""
    _service=$1
    case $DistroBasedOn in
        "debian")
            _initctrl="update-rc.d"
            _init_suffix="defaults"
            ;;
        *)
            _initctrl="chkconfig"
            _init_suffix="on"
            ;;
    esac
    eval "$_initctrl $_service $_init_suffix"
    if [ $? -ne 0 ]; then
        log "$_initctrl $_service $_init_suffix - fails!"
        exit 1
    fi
}
function restart_service(){
    _service="$1"
    service "$_service" restart > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log "Can't start $_service service!"
        exit 1
    fi
}
function package_renamer(){
    _pkg="$1"
    case "$DistroBasedOn" in
        "debian")
            _pkg=$(echo "$_pkg" | sed 's/-devel$/-dev/')
            ;;
        *)
            _pkg=$(echo "$_pkg" | sed 's/-dev$/-devel/')
            ;;
    esac
    echo "$_pkg"
}
function retry()
{
    local n=0
    local try=$1
    local cmd="${*:2}"
    [[ $# -le 1 ]] && {
    echo "Usage $0 <retry_number> <Command>"; }
    until [[ $n -ge $try ]]
    do
        if eval "$cmd"; then
          echo "Command: ${cmd} done.."
          break
        else
            echo "Command Fail.."
            ((n++))
            echo "retry $n ::"
            sleep 1;
        fi
    done
}
