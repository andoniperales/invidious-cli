#!/usr/bin/env bash

IFS=$'\n'

instances=(
yewtu.be vid.puffyan.us yt.artemislena.eu invidious.flokinet.to invidious.projectsegfau.lt invidious.slipfox.xyz invidious.privacydev.net iv.melmac.space iv.ggtyler.dev invidious.lunar.icu inv.nadeko.net inv.tux.pizza invidious.protokolla.fi iv.nboeck.de invidious.private.coffee yt.drgnz.club iv.datura.network invidious.fdn.fr invidious.perennialte.ch youtube.owacon.moe
)

rand=$(
        echo $((RANDOM % 19))
)

instance=$(
        echo ${instances[$rand]}
)

while :; do 
    echo "Enter your search query:"
    read query

    query=$(
        echo $query | 
        sed 's/\s/+/g'
    )
    
    results=$(curl "https://$instance/api/v1/search/?q=$query" -s --retry-all-errors)

    titles=$(
        echo "$results" | 
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
                echo -e "$titles \n"
                echo "Enter the number of the video you want to watch:"

                read n
                
                case $n in
                s | S) break;;
                esac

                echo "Now enter w to watch, d to download, or s to do a new search:"

                read opt

                case $opt in
                w | W) mpv https://$instance/watch?v=${arr_v[$n-1]} --fs; clear;;
                d | D) yt-dlp https://$instance/watch?v=${arr_v[$n-1]}; clear;;
                s | S) break;;
                *) echo "Wrong input; try again"; sleep 1; clear; continue;;
                esac
        done
done
