#!/usr/bin/env bash
## RDesktop GUI Script
## Script To Execute RDesktop In A GUI Environment
## Geoffrey Harrison <geoffrey.harrison@lynxdigital.com.au>

## displayError Function - Displays Error To The User
function displayError {
	if [ -f "/usr/bin/zenity" ]
	then
		zenity --error --text="$1"
	else
		echo
		echo " ERROR: $1"
		echo
	fi
}

## MAIN SCRIPT

# Define Directory and Binary Variables
scriptDir=$(dirname "$0")
credentialsDir="${scriptDir}/credentials"
workingDir="/tmp"
rdesktopBin=$(whereis -b rdesktop | awk '{print $2}')
zenityBin=$(whereis -b zenity | awk '{print $2}')

# Load Script Config Override File If Exists
if [ -f "${scriptDir}/override.conf" ] ; then . "${scriptDir}/override.conf" ; fi

# Check If Server Config File Was Provided On Command Line
if [ "$1" == "" ]
then
	# Prompt User To Provide File Of None
	serverConfig=$(${zenityBin} --file-selection --file-filter="Server Configs | *.rdp")
	guiResult=$?
	if [ $guiResult -eq 1 ]
	then
		displayError "No Server Config File Selected"
		exit 1
	fi
else
	# Server Config File Provided
	serverConfig=$1
fi

# Load Global Defaults If It Exists
if [ -f "${scriptDir}/defaults.conf" ]
then
	. "${scriptDir}/defaults.conf"
else
	# Write If It Doesn't
	touch "${scriptDir}/defaults.conf"
fi

# Check Server Config File Exists
if [ -f "${serverConfig}" ]
then
	# Load Any Group Defaults If They Exist
	configDir=$(dirname ${serverConfig})
	if [ -f "${configDir}/defaults.conf" ]
	then
		. "${configDir}/defaults.conf"
	fi
	
	# Load Config Variables
	. ${serverConfig}
	
	# Load Credentials From Credentials File or Config
	if [ "${credentials}" == "" ]
	then
		# Set Credentials From Variables
		if [ "${username}" == "" ]
		then
			username=$(${zenityBin} --entry --text="Please Enter Username")
			$guiResult=$?
			if [ $guiResult -neq 0 ]
			then
				displayError "No Username Provided"
				exit 1
			fi
		fi
	else
		# Load Credentials From File
		if [ -f "${credentialsDir}/${credentials}.credentials" ]
		then
			. ${credentialsDir}/${credentials}.credentials
		else
			displayError "Credentials File Not Found"
			exit 1
		fi
	fi
	
	# Check Hostname or IPAddress
	if [ ${hostname} != "" ]
	then
		rdpHost="${hostname}"
	else
		if [ ${ipAddress} != "" ]
		then
			rdpHost="${ipAddress}"
		else
			displayError "No Hostname Or IP Address Specified"
			exit 1
		fi
	fi

	## Start Building Command Line For RDesktop
	cmdLine="${rdesktopBin} -c ${workingDir}"
	
	# Screen Resolution
	if [ "${resolution}" == "full" ]
	then
		cmdLine="${cmdLine} -f"
	else
		cmdLine="${cmdLine} -g '$resolution'"
	fi
	
	# RDP Version
	if [ "${rdpVersion}" == "5" ] || [ "${rdpVersion}" == "4" ]
	then
		cmdLine="${cmdLine} -${rdpVersion}"
	else
		displayError "Invalid RDP Version Defined"
		exit 1
	fi
	
	# Compression
	if [ "${compression}" == "true" ]
	then
		cmdLine="${cmdLine} -z"
	fi
	
	# Colour Depth
	if [ "${colorDepth}" != "" ]
	then
		cmdLine="${cmdLine} -a ${colorDepth}"
	fi
	
	# Console
	if [ "${console}" == "true" ]
	then
		cmdLine="${cmdLine} -0"
	fi
	
	# Window Title
	if [ "${title}" != "" ]
	then
		cmdLine="${cmdLine} -T '${title}'"
	else
		cmdLine="${cmdLine} -T '${rdpHost}'"
	fi
	
	# Quality Level (Modem, Boradband, LAN)
	if [ $quality != "" ]
	then
		if [ $quality == "modem" ] ; then cmdLine="${cmdLine} -x m" ; fi
		if [ $quality == "broadband" ] ; then cmdLine="${cmdLine} -x b" ; fi
		if [ $quality == "lan" ] ; then cmdLine="${cmdLine} -x l" ; fi
	fi
	
	# Sound Playback
	if [ "${sound}" == "off" ] || [ "${sound}" == "local" ] || [ "${sound}" == "remote" ]
	then
		cmdLine="${cmdLine} -r sound:${sound}"
	fi
	
	# Clipboard
	if [ "${clipboard}" == "off" ] || [ "${clipboard}" == "primary" ] || [ "${clipboard}" == "clipboard" ]
	then
		if [ "${clipboard}" == "off" ] ; then cmdLine="${cmdLine} -r clipboard:off" ; fi
		if [ "${clipboard}" == "primary" ] ; then cmdLine="${cmdLine} -r clipboard:PRIMARYCLIPBOARD" ; fi
		if [ "${clipboard}" == "clipboard" ] ; then cmdLine="${cmdLine} -r clipboard:CLIPBOARD" ; fi
	fi
	
	# Disk Sharing
	if [ "${disks}" != "" ]
	then
		# Check and Set ClientName For System
		if [ "${clientname}" == "" ]
		then 
			# Set To Username If No Clientname Provided
			cmdLine="${cmdLine} -r clientname:${USER}"
		else
			# Clientname Provided
			cmdLine="${cmdLine} -r clientname:${clientname}"	
		fi
		
		# Set Disks
		for disk in ${disks}
		do
			cmdLine="${cmdLine} -r disk:${disk}"
		done
	fi
	
	# Set A User Domain
	if [ "${domain}" != "" ]
	then
		cmdLine="${cmdLine} -d '${domain}'"
	fi
	
	# Prompt User If No Password
	if [ ${password} == "" ]
	then
		password=$(${zenityBin} --entry --text="Please Enter Password" --hide-text)
		$guiResult=$?
		if [ $guiResult -neq 0 ]
		then
			password=""
		fi
	fi
	
	# Complete Command Line
	cmdLine="${cmdLine} -u '${username}' -p '${password}' '${rdpHost}'"
	
	## Execute Command
	eval "${cmdLine}"
	
else
	displayError "Server Config File Not Found"
	exit 1
fi

# Clean Exit
exit 0

