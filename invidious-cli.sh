#!/bin/bash

echo "Enter your search query"
read query
query_s=$(echo "$query" | sed 's/\s/+/g')

video=$(curl "https://invidious.namazso.eu/api/v1/search/?q=$query_s" -s --retry-all-errors)
list=$(echo "$video" | grep -o -P '"title":"(.+?)","videoId"' | sed s/'"title":"'// | sed s/'","videoId"'// | sed 's:\\::g' | nl -b a)
echo "$list"

echo -e "\nEnter the video number"

while :; do

read number
video_id=$(echo $video | grep -o -E '"videoId":"[^"]+"' | sed -n ''''$number'p''' | sed 's/"videoId"://' | sed 's/"//')

echo -e "\nDo you want to watch it or download it? [w(atch)/d(ownload)]"
read opt
if [[ $opt == "d" ]]; then
    yt-dlp -f 22 https://yewtu.be/watch?v=$video_id
elif [[ $opt == "w" ]]; then
    mpv https://yewtu.be/watch?v=$video_id --fs --ytdl-format=22
else 
    echo -e "\nWrong input, try again"
    sleep 1
fi

clear

echo "$list"
echo -e "\nEnter another number, or quit by pressing Ctrl+C"

done
