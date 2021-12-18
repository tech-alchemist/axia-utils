#!/bin/bash
# Author : Tech-Alchemist (Abhishek Rana)
# Description : Script to Configure NGINX Vhost WSS or HTTPS 

PROTO="$1"
DOMAIN_NAME="$2"
PRIVATE_IP="$3"
PRIVATE_PORT="$4"
UTILS_DIR="/opt/opsdude/axia-utils/extras"

[[ ! -z ${PROTO} ]] || [[ ! -z ${DOMAIN_NAME} ]] || [[ ! -z "${PRIVATE_IP}" ]] || [[ ! -z ${PRIVATE_PORT} ]] || { echo "[-] Usage : $0 <WSS/HTTPS> <DOMAINNAME> <PROXYHOST> <PROXYPORT>" ; exit 1 ; } 

case $PROTO in

  wss | Wss | WSS)
    sed -e "s/DOMAIN_NAME/${DOMAIN_NAME}/g" -e "s|PRIVATE_IP|${PRIVATE_IP}|g" -e "s|PRIVATE_PORT|${PRIVATE_PORT}|g" ${UTILS_DIR}/WSS.conf.example | sudo tee /etc/nginx/sites-enabled/${DOMAINNAME}.conf
    sudo service nginx restart
    ;;


  HTTPS | Https | https)
    sed -e "s/DOMAIN_NAME/${DOMAIN_NAME}/g" -e "s|PRIVATE_IP|${PRIVATE_IP}|g" -e "s|PRIVATE_PORT|${PRIVATE_PORT}|g" ${UTILS_DIR}/HTTPS.conf.example | sudo tee /etc/nginx/sites-enabled/${DOMAINNAME}.conf
    sudo service nginx restart
    ;;

  *)
    echo -n "[-] Unknown Proto Type [PROTO] , Allowed are : WSS or HTTPS"
    ;;

esac

echo "Added ${DOMAINNAME}"

## E O F ##