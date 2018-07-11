#!/usr/bin/env bash
#! /bin/bash
#
# Name: zabbix_php-fpm_monitor-cgi.sh
#
# Checks php-fpm status.
#
# Author: Rafael Rotelok
# Version: 0.9
#

php_mon_version="0.9"
rval=0
value=""
cache_seconds="30"
status_page="/server-status-fpm"

[ "${TMPDIR}" ] || TMPDIR=/tmp

function usage()
{
	echo "zabbix php-fpm monitor version: ${php_mon_version}"
	echo "usage:"
	echo "  Choose your metric ammong the following"
	echo "    pool                   - pool name."
	echo "    processManager         - Type of process manager."
	echo "    startTime              - Started at time."
	echo "    upTime                 - Uptime in seconds ."
	echo "    acceptedConnections    - Number of accepted connections."
	echo "    queue                  - Current size of the listen queue."
	echo "    maxQueue               - Max achieved size of the listen queue."
	echo "    queueLenght            - Max configured size of the listen queue."
	echo "    idle                   - Number of idle process."
	echo "    active                 - Number of active process."
	echo "    total                  - Number of Idle+Active process."
	echo "    maxActive              - Maximun number of active process."
	echo "    maxChildren            - Number of times that MaxChildren was reached."
	echo "    slowRequests           - Number of requests slower than."
	echo "    phpVersion             - The php version the pool is running."
	echo "  And Run"
	echo "  $0 [<url> <port>] <metric>"
	exit;
}

########
# Main #
########

if [[ $# == 1 ]];then
	STATUS_HOST="localhost"
	STATUS_PORT="9000"
    CASE_VALUE="${1}"
elif [[ $# == 3 ]];then
	#Agent Mode
	STATUS_HOST=${1}
	STATUS_PORT=${2}
	CASE_VALUE="${3}"
else
	#No Parameter
	usage
	exit 0
fi

case "${CASE_VALUE}" in
'version')
	echo "${php_mon_version}"
	exit 0;;
esac


#umask 077

# $UID is bash-specific
cache_prefix="php-fpm-mon-${UID}-${STATUS_HOST//[^a-zA-Z0-9_-]/_}"
cache="${TMPDIR}/${cache_prefix}.cache"
cache_timestamp_check="${TMPDIR}/${cache_prefix}.ts"
# This assumes touch from coreutils
touch -d "@$((`date +%s` - (${apche_seconds} - 1)))" "${cache_timestamp_check}"

if [ "${cache}" -ot "${cache_timestamp_check}" ]; then
    progName="`which cgi-fcgi`"
    export SCRIPT_NAME=/server-status-fpm
    export SCRIPT_FILENAME=/server-status-fpm
    export REQUEST_METHOD=GET
    ${progName} -bind -connect ${STATUS_HOST}:${STATUS_PORT} | tr -s ' ' | tr -s '\t' > "${cache}"

	rval=$?
	if [ $rval != 0 ]; then
		echo "ZBX_NOTSUPPORTED"
		exit 1
	fi
fi

case "${CASE_VALUE}" in
'ping')
	if [ ! -s "${cache}" -o "${cache}" -ot "${cache_timestamp_check}" ]; then
		echo "0"
	else
		echo "1"
	fi
	exit 0;;
esac

if ! [ -s "${cache}" ]; then
	echo "ZBX_NOTSUPPORTED"
	exit 1
fi

case "${CASE_VALUE}" in
'phpVersion')
	value="`awk '/^X-Powered-By:/ {print $2}' < \"${cache}\"`"
	rval=${?};;
'slowRequests')
	value="`awk '/^slow requests:/ {print $3}' < \"${cache}\"`"
	rval=${?};;
'maxChildren')
	value="`awk '/^max children reached:/ {print $3}' < \"${cache}\"`"
	rval=${?};;
'maxActive')
	value="`awk '/^max active processes:/ {print $4}' < \"${cache}\"`"
	rval=${?};;
'total')
	value="`awk '/^total processes:/ {print $3}' < \"${cache}\"`"
	rval=${?};;
'active')
	value="`awk '/^active processes:/ {print $3}' < \"${cache}\"`"
	rval=${?};;
'idle')
	value="`awk '/^idle processes:/ {print $3}' < \"${cache}\"`"
	rval=${?};;
'queueLenght')
	value="`awk '/^listen queue len:/ {print $4}' < \"${cache}\"`"
	rval=${?};;
'maxQueue')
	value="`awk '/^max listen queue:/ {print $4}' < \"${cache}\"`"
	rval=${?};;
'queue')
	value="`awk '/^listen queue:/ {print $3}' < \"${cache}\"`"
	rval=${?};;
'acceptedConnections')
	value="`awk '/^accepted conn:/ {print $3}' < \"${cache}\"`"
	rval=${?};;
'upTime')
	value="`awk '/^start since:/ {print $3}' < \"${cache}\"`"
	rval=${?};;
'startTime')
	value="`awk '/^start time:/ {print $3}' < \"${cache}\"`"
	rval=${?};;
'processManager')
	value="`awk '/^process manager:/ {print $3}' < \"${cache}\"`"
	rval=${?};;
'pool')
	value="`awk '/^pool:/ {print $2}' < \"${cache}\"`"
	rval=${?};;
*)
	usage
	exit 1;;
esac

if [ "$rval" -ne 0 ]; then
	echo "ZBX_NOTSUPPORTED"
fi

echo "$value"
exit $rval

#
# end zapache
