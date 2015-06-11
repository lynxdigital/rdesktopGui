#!/bin/bash
## RDesktop GUI Script
## Script To Execute RDesktop In A GUI Environment

# Function set_default - Returns Passed Value Or Pre-Set Default
set_default {
	if [ "$1" == "" ]
	then
		echo $2
	else
		echo $1
	fi
}

# Function display_error - Displays An Error
display_error {
	echo
	echo " ERROR: $1"
	echo
}

# No Config Means No Run
if [ "$1" == "" ]
then
	exit 1
else
	serverConfig=$1
fi

# Define Static Variables
scriptPath="/home/geoffrey/Projects/rdesktopGui"
credentialsPath="${scriptPath}/credentials"

# Check Server Config File
if [ -f ${serverConfig} ]
then
	# Load Config Variables
	. ${serverConfig}
	
	# Load Credentials From Config Or File
	if [ "${credentials}" == "" ]
	then
		if [ "${username}" == "" ]
		then
			display_error "No Credential File Defined And No Username"
			exit 1
		else
			password=$(set_default "${password}" "")
			domain=$(set_default "${domain}" "")
		fi
	else
		# Load Credentials From File
		if [ -f "${credentialsPath}/${credentials}.credentials" ]
		then
			. ${credentialsPath}/${credentials}.credentials
		else
			display_error "Credentials File Not Found"
			exit 1
		fi
	fi
	
	# WORKING####

else
	display_error "Server Config File Not Found"
	exit 1
fi

# Clean Exit
exit 0

