#!/bin/bash

process_like_relay_fedinet_social () {
    relayURL=$2
    contentFile=$3

    relayName=$(echo $2 | cut -d '/' -f3)
    numberOfInstances=$(grep -e '[0-9]* registered instances:' $contentFile | grep -e '[0-9]*' -o -m 1 | head -1)

    eval "$1='${relayName};${numberOfInstances}'"
}

while read eachRelayURL           
do           
    echo "checking $eachRelayURL ..." 
    data=''
    curl -sL "$eachRelayURL" -o content.tmp
    implMarker=$(xmllint --html --xpath 'string(//p)' content.tmp 2>/dev/null)
    if [[ "$implMarker" == "This is an Activity Relay for fediverse instances." ]]; then
        process_like_relay_fedinet_social data $eachRelayURL content.tmp
    fi
    echo $data
    rm content.tmp
done < relays.txt