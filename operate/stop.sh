#!/bin/bash
## Author : Abhishek Rana ##
## Description : Script to Stop Existing Running Axia Node/Apps ##

killer(){
    WORD1="$1"
    WORD2="$2"
    for PID in $(ps aux | grep "${WORD1}" | grep "${WORD2}"| awk '{print $2}')
    do
    sudo kill -9 ${PID} && echo "Killed PID ${PID}"
    done
}

killer axia chain
killer axia Bins

## E O F ##
