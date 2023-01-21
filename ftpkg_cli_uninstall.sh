#!/bin/bash

# Internal arguments

export NO_PRETTY_PRINTING=$1
export SCRIPT_FRIENDLY=$2
export PACKAGENAME=$3
export PASSWORD=$4

if [ "$NO_PRETTY_PRINTING" != "1" ]; then
	# Ansi color code variables
	export red="\e[0;91m"
	export blue="\e[0;94m"
	export expand_bg="\e[K"
	export blue_bg="\e[0;104m${expand_bg}"
	export red_bg="\e[0;101m${expand_bg}"
	export green_bg="\e[0;102m${expand_bg}"
	export green="\e[0;92m"
	export white="\e[0;97m"
	export bold="\e[1m"
	export uline="\e[4m"
	export reset="\e[0m"
fi

print()
{
	echo -ne "$1$2$3$reset"
}

if [ "$PASSWORD" == "" ]; then
	print "$blue" "$bold" "[INFO]"
	print "" "" " - Running Docker to get the required ftpkg password. This can take a little bit of time. Especially on Mac dumps.\n"
	docker compose -f $PWD/docker/docker-compose.yaml build --quiet
	PASSWORD=$(docker compose -f $PWD/docker/docker-compose.yaml run --quiet-pull get_ftpkg_password)
fi

# Initial CURL - removing '"icon": "<anything>",' with sed
STATUS=$(curl -s "http://localhost:4242/uninstall/$PASSWORD/$PACKAGENAME")
# TODO: extend cases in which the result could be invalid
echo "$STATUS" | grep -qs "404 Not Found"
STATUS_RESULT=$?

if [ ! "$STATUS_RESULT" ] || [ "$STATUS" == "KO" ] || [ "$STATUS" == "NOT FOUND" ] || [ "$STATUS" == "" ]; then
	print "$red" "$bold" "[FAIL]"
	if [ "$STATUS" == "" ]; then
		print "" "" " - The server did not respond.\n"
	elif [ "$STATUS" == "NOT FOUND" ]; then
		print "" "" " - Your package was not found.\n"
	elif [ "$STATUS" == "KO" ]; then
		print "" "" " - Your password is incorrect.\n"
	else
		print "" "" " - Here are more details.\n"
		echo "$STATUS"
	fi;
	exit 1;
fi

print "$green" "$bold" "[OK]"
print "" "" " - Package $PACKAGENAME is being uninstalled.\n"
exit 0;
