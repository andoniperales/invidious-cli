#!/usr/bin/env bash

IFS=$'\n'

while :; do 
    echo "Enter your search query"
    read query

    query=$(
        echo $query | 
        sed 's/\s/+/g'
    )
    
    results=$(curl "https://invidious.namazso.eu/api/v1/search/?q=$query" -s --retry-all-errors)

    titles=$(
        echo "$results" | 
        grep -oP '(?<="title":")(.+?)(?=","videoId")' | 
        nl -b a
    )
    
    arr_t=($titles)
    
    video_ids=$(
        echo $results | 
        grep -oP '(?<="videoId":")[^"]+?(?=")'
    )

    arr_v=($video_ids)

    for (( n=0;;))
    do
        clear
        echo -e "Results:"
        echo ${arr_t[$n]}
        echo -e "\n n(ext)/p(revious)/w(atch)/d(ownload)/s(earch)"
        read opt 
        case $opt in
            n | N) clear; (( n++ )); continue;;
            p | P) clear; (( n-- )); continue;;
            w | W) mpv https://yewtu.be/watch?v=${arr_v[$n]} --fs; clear;;
            d | D) yt-dlp -f 22 https://yewtu.be/watch?v=${arr_v[$n]}; clear;;
            s | S) clear; break;;
            *) echo "Wrong input; try again"; sleep 1; clear; continue;;
        esac
    done 
    
done
