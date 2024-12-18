#!/usr/bin/env bash

IFS=$' '

arr_inst=(https://yewtu.be https://inv.nadeko.net https://invidious.jing.rocks)

for i in ${!arr_inst[@]}; do
    instance_response=$(curl --head "${arr_inst[$i]}/api/v1/search?q=test" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36" -s | head -n 1 | grep -oP '\d{3}')
    case $instance_response in
        200) instance=${arr_inst[$i]}; break;;
        *) :;;
    esac
done

INV_API="$instance/api/v1/search"
IFS=$'\n'

while :; do
        echo "Enter your search query:"
        read query

        query=$(
                echo $query | 
                sed 's/\s/+/g'
        )

        results=$(curl "$INV_API/?q=$query" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36" -s --retry-all-errors)

        titles=$(
                echo $results | 
                grep -oP '(?<="title":")(.+?)(?=",")' | 
                sed 's/\\"/\"/g' |
                nl -b a
        )
        
        video_ids=$(
                echo $results | 
                grep -oP '(?<="videoId":")[^"]+?(?=")'
        )

        arr_v=($video_ids)

        while :; do
                echo "$titles"
                
                echo -e "\nEnter the number of the video you want to watch ('s' to do a new search, 'q' to quit):"
                
                read n
                
                VID="$instance/watch?v=${arr_v[$n-1]}"       
                
                case $n in
                s | S) break;;
                q | Q) exit;;
                esac

                echo "Now enter 'w' to watch, 'd' to download, 's' to do a new search, 'q' to quit:"

                read option

                case $option in
                w | W) mpv $VID --fs; clear;;
                d | D) yt-dlp $VID; clear;;
                s | S) break;;
                q | Q) exit;;
                *) echo "Wrong input; try again"; sleep 1; clear; continue;;
                esac
        done
done
