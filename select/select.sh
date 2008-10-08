#!/bin/bash
#
# $Id$
#
# Copyright (c) 2007-2008 The MacPorts Project
# Copyright (c) 2007 Markus W. Weissmann <mww@macports.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of OpenDarwin nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

## configuration time options
PREFIX=__PREFIX__
NAME=__NAME__
TOOL=${NAME}_select
CONFPATH=${PREFIX}/etc/select/${NAME}
VERSION=__VERSION__
SELECTEDVERSION=${CONFPATH}/.current


## GLOBALS
# dont actually execute, just show what would have been done
noexec=0
# enable debug mode
debug=0
# enforce action
force=0
# skip check for required rights
isroot=0
# perform "install" mode (for initial destroot)
inst_mode=0
DESTDIR=""


# print the usage of this tool
usage() {
	cat <<EOD
usage: ${TOOL} [-n] [-d] [-f] [-r] [-h] [-v] version

-n        Show commands to do selection but do not execute them.
-d        Show debug messages during execution
-f        Ensure the links are correct for the specified version
          even if it maches the current default version.
-h        Display this help info.
-r        Skip test for necessary rights.
-v        Display version of ${TOOL}.
-l        List available options for version.
-i path   Install mode to perform an initial selection in path.
-s        Show the currently selected version

EOD
}

# print the version of this tool
version() {
	echo "${TOOL} v${VERSION}"
}

# list all (currently) available versions
list_version() {
	echo "Available versions:"
	echo $(ls -1 ${CONFPATH} | grep -v base)
}

# list the currently selected version
list_current_selection() {
	if [ -e ${SELECTEDVERSION} ]; then
		cat ${SELECTEDVERSION}
	else
		echo "none"
	fi
}

# test if a particular version is available
version_is_valid() {
	for version in $(ls -1 ${CONFPATH} | grep -v base); do
		if [ "${1}" == "${version}" ]; then
			return 0
		fi
	done
	return 1
}

# perform an action (command) or just display it
action() {
	if [ "rm" == "${1}" ]; then
		if [ 1 == "${noexec}" ]; then
			echo "rm -f ${2}"
		else
			rm -f ${2}
		fi
	elif [ "ln" == "${1}" ]; then
		if [ 1 == "${noexec}" ]; then
			echo "ln -sf ${2} ${3}"
		else
			ln -sf ${2} ${3}
		fi
	else
		return 1
	fi
}

# change symlinks
select_version() {
	# count the number of errors
	local error=0
	local i=1
	echo "Selecting version \"${1}\" for ${NAME}"
	if [ 1 == ${noexec} ]; then
		echo "echo ${1} >| ${SELECTEDVERSION}"
	else
		echo ${1} >| ${SELECTEDVERSION}
	fi
	for target in $(cat ${CONFPATH}/base); do
		if [ "${1}" == "none" ]; then
			src="-"
		else
			src=$(head -n ${i} ${CONFPATH}/${1} | tail -n 1)
		fi

		# test if line starts with '-' -> dont link, just rm original
		if [ "-" == $(echo ${src} | colrm 2) ]; then
			# source is unavailable for this file
			action "rm" "${DESTDIR}${PREFIX}/${target}"
		elif [ "/" == $(echo ${src} | colrm 2) ]; then
			# source has an absolute path
			action "ln" "${src}" "${DESTDIR}${PREFIX}/${target}"
		else
			# source has relative path
			action "ln" "${PREFIX}/${src}" "${DESTDIR}${PREFIX}/${target}"
		fi
		let "error = error + ${?}"
		let "i = i + 1"
	done
	return ${error}
}


if [ ${#} == 0 ]; then
	usage
	exit 2
fi

# parse command line args
args=$(/usr/bin/getopt i:fhndlrsv $*)
set -- ${args}
for i; do
	case "${i}" in
		-h)
			usage; exit 0;;
		-n)
			noexec=1; shift;;
		-f)
			force=1; shift;;
		-d)
			debug=1; shift;;
		-l)
			list_version; exit 0;;
		-r)
			isroot=1; shift;;
		-v)
			version; exit 0;;
		-i)
			inst_mode=1; DESTDIR=${2}; shift; shift;;
		-s)
			list_current_selection; exit 0;;
		--)
			shift; break;;
	esac
done

# enable debug output if requested
if [ "1" = "${debug}" ]; then
    set -x
fi

# install mode - bypass all checks and add DESTDIR
if [ "1" = "${inst_mode}" ]; then
	echo "install mode: destroot: \"${DESTDIR}\""
	CONFPATH=${DESTDIR}${CONFPATH}
	SELECTEDVERSION=${CONFPATH}/.current
	select_version ${1}
	exit ${?}
fi

# test if chosen version is available
version_is_valid $1
if [ 0 != ${?} ]; then
	echo "version \"$1\" is invalid!"
	exit 4
fi

# execute selection
select_version ${1}
error_count=${?}
if [ 0 != ${error_count} ]; then
	echo "there were ${error_count} errors selecting version \"${version}\"!"
	exit 5
fi

exit 0

