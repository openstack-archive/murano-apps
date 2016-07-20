#!/bin/bash -ex

#   .. module:: apps_uploader.sh
#       :platform: Ubuntu. Linux
#       :synopsis: Zip murano-app's from directory, and upload them to OpenStack.
#   .. author:: Alexey Zvyagintsev <azvyagintsev@mirantis.com>

#   .. Require: apt-get install zip python-muranoclient

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKSPACE="${WORKSPACE:-${DIR}}"
#
DEFAULT_ARTIFACTS_DIR="${WORKSPACE}/artifacts/"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-$DEFAULT_ARTIFACTS_DIR}"
#
# Prefix require for deleting OLD app from app-list
# example for app "io.murano.apps.docker.kubernetes.KubernetesPod"
APP_PREFIX="${APP_PREFIX:-io.test_upload.}"
#
# whole path to package will be: GIT_ROOT/APPS_ROOT/PACKAGES_LIST/package
APPS_ROOT="${APPS_ROOT:-/murano-apps/}"
APPS_DIR="${WORKSPACE}/${APPS_ROOT}/"
#
# Upload app's to OpenStack?
UPLOAD_TO_OS="${UPLOAD_TO_OS:-false}"
#
# List of murano app catalogs, to be archived and uploaded into OS
#PACKAGES_LIST="Puppet SystemConfig OpenLDAP Gerrit Jenkins"


function verify_vars() {
    if [[ -z "OS_PASSWORD" ]]; then
        echo "OS_PASSWORD env variable not provided."
        exit 1
    fi
    if [[ -z "OS_USERNAME" ]]; then
        echo "OS_USERNAME env variable not provided."
        exit 1
    fi
    if [[ -z "PACKAGES_LIST" ]]; then
        echo "PACKAGES_LIST env variable not provided."
        exit 1
    fi
}


function build_packages() {
   for pkg_long in ${PACKAGES_LIST}; do
       local pkg=$(basename "${pkg_long}")
       art_name="${ARTIFACTS_DIR}/${APP_PREFIX}${pkg}.zip"
       pushd "${APPS_DIR}/${pkg_long}/package"
       zip -r "${art_name}" ./*
       popd
   done
}

# Body

verify_vars

mkdir -p "${ARTIFACTS_DIR}"
echo STARTED_TIME="$(date -u +'%Y-%m-%dT%H:%M:%S')" > "${ARTIFACTS_DIR}/ci_status_params.txt"

# import default packages_list, if exist
if [ -f "${WORKSPACE}/tools/default_packages_list.sh" ]; then
    if [ -z "${DEFAULT_PACKAGES_LIST}" ]; then
        source "${WORKSPACE}/tools/default_packages_list.sh"
        if [ -z "${PACKAGES_LIST}" ]; then
            echo "Packages list has been imported from default_packages_list.sh file"
            PACKAGES_LIST="${DEFAULT_PACKAGES_LIST}"
        fi
    fi
fi

# remove arts from previous run
echo  'LOG: printenv:'
printenv | grep -vi "PASSWORD"
find "${ARTIFACTS_DIR}" -type f -exec rm -fv {} \;

if [[ ! -z "${PACKAGES_LIST}" ]] ; then
    build_packages
fi

if [[ "${UPLOAD_TO_OS}" == true ]] ; then
    echo "LOG: murano version: $(murano --version)"
    # Some app's have external dependency's
    # - so we should have ability to clean-up them also
    if [[ "${APPS_CLEAN}" == true ]]; then
        echo  'LOG: Removing ALL apps from tenant...'
        echo  'LOG: Apps in tenant:'
        murano package-list --owned
        pkg_ids=($(murano package-list --owned |grep -v 'ID\|--' |awk '{print $2}'))
        for id in "${pkg_ids[@]}"; do
            murano package-delete "${id}" || true
        done
    fi
    # to have ability upload one package independently we need to remove it
    echo "LOG: removing old packages..."
    for pkg_long in ${PACKAGES_LIST}; do
        pkg=$(basename "${pkg_long}")
        art_name="${ARTIFACTS_DIR}/${APP_PREFIX}${pkg}.zip"
        pkg_id=$(murano package-list --owned |awk "/$pkg/ {print \$2}")
        if [[ -n "${pkg_id}" ]] ; then
            # FIXME remove 'true', after --owned flag will be fixed
            # https://bugs.launchpad.net/mos/+bug/1593279
            murano package-delete "${pkg_id}" || true
        fi
    done
    # via client and then upload it without updating its dependencies
    echo "LOG: importing new packages..."
    echo "WARNING: Exist packages will be skipped"
    for pkg_long in ${PACKAGES_LIST}; do
        pkg=$(basename "${pkg_long}")
        art_name="${ARTIFACTS_DIR}/${APP_PREFIX}${pkg}.zip"
        murano package-import "${art_name}" --exists-action s
    done
    echo "LOG: importing done, final package list:"
    murano package-list --owned
fi

echo FINISHED_TIME="$(date -u +'%Y-%m-%dT%H:%M:%S')" >> "${ARTIFACTS_DIR}/ci_status_params.txt"
