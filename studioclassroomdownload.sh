#!/bin/bash

if [ -n "$1" ]; then
	cd $1
fi

#SERVER="ala-lpggp4.wrs.com"
SERVER="ala-lpd-susbld2.wrs.com"
F_PATH="/buildarea/raid0/fli/"
BASEURL="http://sc.streamingfast.net"
URL=""

if [ -n "$3" ]; then
	DATE="$3"
else
	DATE=$(date "+%Y-%m-%d")
fi
#DATE="2017-09-02"
date=`echo $DATE | sed 's/\-//g'`
#date="20170902"
down_upload_vedio(){
	rm -rf index.html
	#tsocks wget http://w2.goodtv.tv/studio_classroom/?d=$(date "+%Y-%m-%d") -O index.html
	ssh fli@${SERVER}  wget http://w2.goodtv.tv/studio_classroom/?d=$DATE -O index.html && scp fli@${SERVER}:~/index.html  ./
	url=`cat index.html  |  grep 'source src="http://sc.streamingfast.net/hls-vod/sc' | awk '{print $2}' | sed  's/^.*\(http:.*m3u8\).*$/\1/'`
	
#	url="http://sc.streamingfast.net/hls-vod/sc/X902001_6442.m3u8"
	grep $date ./studioclassroom.txt
	if [ $? != 0 ]; then	
		echo "$date	$url" >>./studioclassroom.txt
        else:
            url=`grep $date ./studioclassroom.txt | awk '{print $2}'`
	fi
	fname=${date}.mp4
#	fname="20170830.mp4"
	rm -rf ./vedio/$fname
#	ssh fli@${SERVER} ffmpeg -i $url -bsf:a aac_adtstoasc -c copy $F_PATH/$fname && scp fli@${SERVER}:$F_PATH/$fname ./vedio/
	get_real_url $url
echo	tsocks ffmpeg -i $URL -bsf:a aac_adtstoasc -c copy $fname
	tsocks ffmpeg -i $URL -bsf:a aac_adtstoasc -c copy ./vedio/$fname
	if [ $? != 0 ]; then
		ssh fli@${SERVER} ffmpeg -i $url -bsf:a aac_adtstoasc -c copy $F_PATH/$fname && scp fli@${SERVER}:$F_PATH/$fname ./vedio/
	fi 
	bypy upload ./vedio/$fname  studioclassroom/$fname
}

get_real_url(){
	local url=$1
	local temp="local.txt"
	
	rm -rf $temp
	wget -c $url -O $temp
	size="2000k 1200k 500k"

	for s in $size; do 
		last_url=`grep $s $temp`
		if [ -n $last_url ]; then
			URL=$BASEURL${last_url}
			break
		fi
	done
}

down_upload_audio(){
	local fname=`echo $date | sed  's/^20//'`
	local classes="LT SC AD"
	for i in $classes; do
		class=`echo $i | tr A-Z a-z`
		while true; do
			_down_upload_audio $class $i${fname}
			break
			size_num=`ls -hs $class/$i${fname}.MP3 | awk '{print $1}' | sed 's/[K|M|G]//g'`
#			if [ $size_num -ge 10 ]; then
#				break
#			fi
		done
	done
}

_down_upload_audio(){
	class=$1
	name=$2

	rm -rf ${class}/${name}.MP3

	wget -c http://www.studioclassroom-china.com/sites/default/files/${name}.MP3 -O ${class}/${name}.MP3
	if [ $? != 0 ]; then
		for j in {0..9}; do
			wget http://www.studioclassroom-china.com/sites/default/files/${name}_$j.MP3 -O ${class}/${name}.MP3
			if [ $? == 0 ]; then
				break
			fi
		done
	fi

	bypy upload ${class}/${name}.MP3 $class/${name}.MP3
}


if [ $2 == "vedio" ]; then
	down_upload_vedio
elif [ $2 == "audio" ]; then
	down_upload_audio
fi
