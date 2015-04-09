#!/bin/bash
#
INSTALLER_OPTS=""
UNINSTALLER_OPTS=""
PMGR=""
PMGR_LIST_OPTS=""

function include(){
    curr_dir=$(cd $(dirname "$0") && pwd)
    inc_file_path=$curr_dir/$1
    if [ -f "$inc_file_path" ]; then
        . $inc_file_path
    else
        exit 1
    fi
}
function set_install_options(){
    case $1 in
        apt-get )
            INSTALLER_OPTS="-y -q install"
            UNINSTALLER_OPTS="-y -q remove"
            PMGR="dpkg"
            PMGR_LIST_OPTS="-s"
            ;;
        yum )
            INSTALLER_OPTS="--assumeyes install"
            UNINSTALLER_OPTS="--assumeyes erase"
            PMGR="rpm"
            PMGR_LIST_OPTS="-q"
            ;;
        urpm* )
            INSTALLER_OPTS="-y"
            UNINSTALLER_OPTS=""
            PMGR="rpm"
            PMGR_LIST_OPTS="-q"
            ;;
        zypper )
            INSTALLER_OPTS="install"
            UNINSTALLER_OPTS="remove --quiet"
            PMGR="rpm"
            PMGR_LIST_OPTS="-q"
            ;;
        pip )
            INSTALLER_OPTS="install"
            UNINSTALLER_OPTS="uninstall --yes"
            find_pip
            PACKAGER=$PIPCMD
            PMGR=$PIPCMD
            PMGR_LIST_OPTS="freeze | grep"
            ;;
        * )
            exit 1
            ;;
    esac
    PACKAGER=$(which $1)
    if [ $? -ne 0 ]; then
        log "Can't find \"$1\", exiting!"
        exit 1
    fi
}
function package_install(){
    PKG=$1
    eval "$PMGR $PMGR_LIST_OPTS $PKG" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log "\"$PKG\" already installed"
    else
        log "Installing \"$PKG\" ..."
        $PACKAGER $INSTALLER_OPTS $PKG > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            log "\"$PKG\" installation fails, exiting!"
            exit 1
        else
            log "\t\t...success"
        fi
    fi
}
function package_uninstall(){
    PKG=$1
    eval "$PMGR $PMGR_LIST_OPTS $PKG" > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        log "\"$PKG\" not installed"
    else
        log "Unnstalling \"$PKG\" ..."
        $PACKAGER $UNINSTALLER_OPTS $PKG > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            log "\"$PKG\" uninstallation fails, exiting!"
            exit 1
        else
            log "\t\t...success"
        fi
    fi
}
function run_install(){
    for PKG in $@
    do
        package_install $PKG
    done
}
function run_uninstall(){
    for PKG in $@
    do
        package_uninstall $PKG
    done
}
# Main workflow
include "common.sh"
if [ $# -eq 0 ]; then
    script=$(basename $0)
    echo -e "Usage:\n\t* install packages -- ./$script -p package_manager -i package0 [packageN]\n\t* remove packages -- ./$script -p package_manager -r package0 [packageN]"
    exit 1
fi
Packager=''
get_os
if [ $? -ne 0 ]; then
    log "Unsupported *nix version ($DistroBasedOn - $DIST/$PSUEDONAME/$REV/$MACH)"
    exit 1
fi
while getopts ":p:i:r:" opt ; do
    case "$opt" in
        p)
            if [[ "$OPTARG" != sys ]]; then
                Packager=$OPTARG
            fi
            set_install_options $Packager
            ;;
        i)
            n=$OPTARG
            run_install $(collect_args $n $@)
            break;
            ;;
        r)
            n=$OPTARG
            run_uninstall $(collect_args $n $@)
            break;
            ;;
        \?)
            log "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))