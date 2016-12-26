#!/bin/bash
tag=0
name=""
path=""
url=""
branch=""

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
		echo name=$name
		;;
		2)
		path=`echo $line | awk '{print $3}'`
		echo path=$path
		;;
		3)
		rawurl=`echo $line | awk '{print $3}'`
		echo $rawurl | grep '^git' >/dev/null 2>&1
		if [ $? == 0 ]; then
			url=$rawurl
		else
			url="https://github.com/WindRiver-OpenSourceLabs/"`echo $rawurl | awk -F'/' '{print $2}'`
		fi
		echo url=$url
		;;
		4)
		branch=`echo $line | awk '{print $3}'`
		echo branch=$branch

		git submodule add -b $branch --name $name -- $url $path
		;;

	esac

done<$1
