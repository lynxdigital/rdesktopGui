# displayError - Displays Error To The User
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
