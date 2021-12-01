#!/bin/bash
## Author : Abhishek Rana ##
## Script to send Alerts via Telegram Bot ##

NOTIFTYPE="$1"

VAR2="$2"
VAR3="$3"
VAR4="$4"
VAR5="$5"

source /opt/opsdude/axia-utils/extras/tg.conf || { echo "[-] Bot credentials not added @ /opt/opsdude/axia-utils/extras/tg.conf , Refer to axia-utils ReadMe.md" ; }

helpy(){ echo "[-] Usage : $0 <monit/jenkins> <ARG2> <ARG3> <ARG4> <ARG5>" ; }

case $NOTIFTYPE in

  monit | Monit | MONIT)
    # $0 NETWORK NODEIP NODESTATE MESSAGE 
    MESSAGE="<b>Monitor</b> <b>Network</b> : ${VAR2} <b>Node</b> : ${VAR3} <b>State</b> : ${VAR4} <b>Message</b> : ${VAR5}" 
    ;;

  jenkins | Jenkins | JENKINS)
    # $0 NETWORK PROJECT BRANCH BUILDNUM 
    MESSAGE="<b>Jenkins Build</b><br><b>Network</b> : ${VAR2}<br><b>Project</b> : ${VAR3}<br><b>Branch</b> : ${VAR4}<br><b>Build </b> : ${VAR5}" 
    ;;

  *)
    echo -n "[-] Unknown Notification Type"
    ;;

esac

curl -sLk -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHATID} -d parse_mode="HTML" -d text="${MESSAGE}" &> /dev/null && echo "[+] Message Sent to Telegram"

## E o F ##
