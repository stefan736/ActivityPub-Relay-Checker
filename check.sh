#!/bin/bash

process_like_relay_fedi_tools () {
    relayURL=$2
    contentFile=$3

    relayName=$(echo $2 | cut -d '/' -f3)
    numberOfInstances=$(xmllint --html --xpath "count(/html/body/div[1]/div[8]/div//li)" $contentFile 2>/dev/null)

    eval "$1='${relayName};${numberOfInstances}'"
}

process_like_relay_beckmeyer_us () {
    relayURL=$2
    contentFile=$3

    relayName=$(echo $2 | cut -d '/' -f3)
    numberOfInstances=$(grep -Eo '[0-9]* Connected Servers' $contentFile | grep -e '[0-9]*' -o -m 1 | head -1)

    eval "$1='${relayName};${numberOfInstances}'"
}

process_like_relay_fedinet_social () {
    relayURL=$2
    contentFile=$3

    relayName=$(echo $2 | cut -d '/' -f3)
    numberOfInstances=$(grep -e '[0-9]* registered instances:' $contentFile | grep -e '[0-9]*' -o -m 1 | head -1)

    eval "$1='${relayName};${numberOfInstances}'"
}


process_unkown () {
    relayURL=$2
    contentFile=$3

    relayName=$(echo $2 | cut -d '/' -f3)
    numberOfInstances="<unknown>"

    eval "$1='${relayName};${numberOfInstances}'"
}

echo "" > relays_metadata.csv

while read eachRelayURL           
do           
    echo "checking $eachRelayURL ..." 
    data=''
    curl -sL "$eachRelayURL" -o content.tmp
    
    if [[ "$eachRelayURL" == "https://relay.fedi.tools" ]]; then
        process_like_relay_fedi_tools data $eachRelayURL content.tmp
    fi

    if grep -q 'Akkoma' content.tmp; then
        process_like_relay_beckmeyer_us data $eachRelayURL content.tmp
    fi

    implMarker=$(xmllint --html --xpath 'string(//p)' content.tmp 2>/dev/null)
    if [[ "$implMarker" == "This is an Activity Relay for fediverse instances." ]]; then
        process_like_relay_fedinet_social data $eachRelayURL content.tmp
    fi

    if [[ "$data" == "" ]]; then
        process_unkown data $eachRelayURL content.tmp
    fi

    echo $data >> relays_metadata.csv
    rm content.tmp
done < relays.txt