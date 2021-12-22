#!/bin/bash
## Author : Tech-Alchemist (Abhishek Rana)
## Description : Script to Configure NGINX Vhost WSS or HTTPS 
## Usage : ./this_script <DOMAIN_NAME> <PRIVATE_IP> <PRIVATE_PORT>

DOMAIN_NAME="$1"
PRIVATE_IP="$2"
PRIVATE_PORT="$3"
UTILS_DIR="/opt/opsdude/axia-utils/extras"

[[ ! -z ${DOMAIN_NAME} ]] || [[ ! -z "${PRIVATE_IP}" ]] || [[ ! -z ${PRIVATE_PORT} ]] || { echo "[-] Usage : $0 <DOMAINNAME> <PROXYHOST> <PROXYPORT>" ; exit 1 ; } 

sed -e "s/DOMAIN_NAME/${DOMAIN_NAME}/g" -e "s|PRIVATE_IP|${PRIVATE_IP}|g" -e "s|PRIVATE_PORT|${PRIVATE_PORT}|g" ${UTILS_DIR}/nginx.conf.example | sudo tee /etc/nginx/sites-enabled/${DOMAIN_NAME}.conf
sudo service nginx restart

echo "" ; echo "[+] Mapped ${DOMAIN_NAME} to /etc/nginx/sites-enabled/${DOMAIN_NAME}.conf" ; echo ""

## E O F ##