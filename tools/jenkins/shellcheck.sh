#!/bin/bash

WORKSPACE="${WORKSPACE:-${1}}"

function help_m() {
    cat <<-EOF
	***********************************************************************
	Shellcheck script help message:
	Please use env variable:
	- Set directory for scan:
	export WORKSPACE='/dir/with/sh/files/to/scan'
	- or directly:
	./shellcheck.sh "/dir/with/sh/files/to/scan"
	***********************************************************************
	EOF
}

function run_check() {
    local e_count=0

    cat <<-EOF
	***********************************************************************
	*
	*   Starting shellcheck against dir:"${WORKSPACE}"
	*
	***********************************************************************
	EOF
    while read -d '' -r script; do
        unset RESULT
        shellcheck "${script}"
        RESULT=$?
        if [ ${RESULT} != 0 ]; then
            ((e_count++))
        fi
    done < <(find "${WORKSPACE}" -name '*.sh' -print0)
    cat <<-EOF
	***********************************************************************
	*
	*   shellcheck finished with ${e_count} errors.
	*
	***********************************************************************
	EOF
    if [ "${e_count}" -gt 0 ] ; then
        exit 1
    fi
}

### Body:

if [[ -z "${WORKSPACE}" ]]; then
   echo "ERROR: \${WORKSPACE} variable bot set!"
   help_m
   exit 1
fi
run_check
