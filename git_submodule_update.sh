#!/bin/bash
tag=0
name=""
path=""
url=""
branch=""

submodules='.gitmodules'

if [ ! -e "$submodules" ]; then
	echo "Error: cannot find file $submodules, did you in an git repo with submodules?"
	exit 1
fi

while read line; do
	echo $line | grep '\[submodule' >/dev/null 2>&1
	if [ $? == 0 ]; then
		tag=1
	else
		tag=`expr $tag + 1`
	fi

	case $tag in
		1)
		name=`echo $line | awk '{print $2}' | sed 's/[\"|\]]//g' | sed 's/\"//g'`
		;;
		2)
		path=`echo $line | awk '{print $3}'`
		;;
		3)
		rawurl=`echo $line | awk '{print $3}'`
		echo $rawurl | grep '^git' >/dev/null 2>&1
		if [ $? == 0 ]; then
			url=$rawurl
		else
			url="https://github.com/WindRiver-OpenSourceLabs/"`echo $rawurl | awk -F'/' '{print $2}'`
		fi
		;;
		4)
		branch=`echo $line | awk '{print $3}'`

		echo "===checkout git repo $name to branch $branch==="
		cd $path 
		git checkout $branch 
		git pull 
		cd -
		;;

	esac

done<$submodules
