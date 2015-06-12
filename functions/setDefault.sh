# setDefault - Returns Either The User Provided Value Or A Second Default Value
function setDefault {
	if [ "$1" == "" ]
	then
		echo $2
	else
		echo $1
	fi
}