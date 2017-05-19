#!/bin/bash

cd $1
rm -rf index.html
tsocks wget http://w2.goodtv.tv/studio_classroom/?d=$(date "+%Y-%m-%d") -O index.html
url=`cat index.html  |  grep 'source src="http://sc.streamingfast.net/hls-vod/sc' | awk '{print $2}' | sed  's/^.*\(http:.*m3u8\).*$/\1/'`
fname=$(date "+%Y%m%d").mp4
rm -rf $fname
ffmpeg -i $url -bsf:a aac_adtstoasc -c copy $fname
bypy upload $fname  studioclassroom/$fname
