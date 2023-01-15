#!/bin/bash

# Internal arguments

export NO_PRETTY_PRINTING=$1
export SCRIPT_FRIENDLY=$2
export HIDE_NON_INSTALLED=$3

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

# Filename tmp
export tmp_filename;

print_echo()
{
	echo -ne "$1$2$3$reset"
}

print()
{
	echo -ne "$1$2$3$reset" >> "/tmp/$tmp_filename"
}

tmp_filename=$(echo -ne "ftpkg_"; date +%s)
if [ "$SCRIPT_FRIENDLY" != "1" ]; then
	touch "/tmp/$tmp_filename"
fi

# Initial CURL - removing '"icon": "<anything>",' with sed
STATUS=$(curl -s http://localhost:4242/status)
# TODO: extend cases in which the result could be invalid
echo "$STATUS" | grep -qs "404 Not Found"
STATUS_RESULT=$?

if [ ! "$STATUS_RESULT" ] || [ "$STATUS" == "" ]; then
	print_echo "$red" "$bold" "[FAIL]"
	if [ "$STATUS" == "" ]; then
		print_echo "" "" " - the server did not respond.\n"
	else
		print_echo "" "" " - here are more details.\n"
	fi
	echo "$STATUS"
	exit 0;
fi

STATUS=$(echo "$STATUS" | sed "s/ \"icon\": \"\([^\"]*\)\"\,//gm" | sed "s/{/\n/g" | sed "s/},*/\n}/g" | tail -n+3 | sed "/\}/d" | sed "s/\"\([^\"]*\)\": //g" | sed "s/\", /;/g" | tr -d "\"" | sort -t\; -dk3)

if [ "$HIDE_NON_INSTALLED" == "1" ]; then
	STATUS=$(echo "$STATUS" | sed "/0$/d")
fi

if [ "$SCRIPT_FRIENDLY" == "1" ]; then
	echo "name;package_name;category;version;description;installed_state"
	echo "$STATUS"
	exit 1;
fi

print_package_info()
{
	print "" "" "\t"
	print "" "$bold" "Package name: "
	print "" "" "$1\n"
	print "" "" "\t"
	print "" "$bold" "Version: "
	print "" "" "$2\n"
	print "" "" "\t"
	print "" "$bold" "Description: "
	print "" "" "$3\n"
}

export CUR_CATEGORY=""

pretty_print_line()
{
	NAME=$(echo "$1" | cut -d';' -f1)
	PACKAGE_NAME=$(echo "$1" | cut -d';' -f2)
	CATEGORY=$(echo "$1" | cut -d';' -f3)
	VERSION=$(echo "$1" | cut -d';' -f4)
	DESCRIPTION=$(echo "$1" | cut -d';' -f5)
	INSTALL_STATE=$(echo "$1" | cut -d';' -f6)

	if [ "$CUR_CATEGORY" != "$CATEGORY" ]; then
		export CUR_CATEGORY=$CATEGORY
		print "$blue_bg" "" "$CATEGORY"
		print "" "" "\n"
	fi

	if [ "$INSTALL_STATE" == "1" ]; then
		print "$green" "$bold" "[installed] "
	else
		print "$red" "" "[not installed] "
	fi

	print "" "" "$NAME\n"
	print_package_info "$PACKAGE_NAME" "$VERSION" "$DESCRIPTION"
}

export I=1;
export CLINE=" "
while true; do
	BUFFER=$(echo "$STATUS" | head -n"$I" | tail -n1)
	if [ "$BUFFER" == "$CLINE" ]; then
		break ;
	fi
	CLINE=$BUFFER
	pretty_print_line "$CLINE"
	I=$((I+1))
done;

less "/tmp/$tmp_filename"
rm "/tmp/$tmp_filename"
