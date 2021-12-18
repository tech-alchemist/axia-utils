#!/bin/bash
# Author : Tech-Alchemist (Abhishek Rana)
# Description : Script to configure AXIA Telemetry on fresh Machine

SPACE="/home/AXIA"
LOGDIR="${SPACE}/Data/Logs"
BRANCH="$1" ; [[ -z ${BRANCH} ]] && BRANCH="master"
CLEANUP="$2" ; [[ -z ${CLEANUP} ]] && CLEANUP="false"
PM2="/usr/local/bin/pm2"

## Install required packages ##
echo "[+] Well, It's a fresh Node, Setting up from scratch."
sudo apt -y install npm jq net-tools git curl libssl-dev libffi-dev clang llvm libudev-dev expect wget librust-openssl-dev python3-dev python3 python3-pip
echo "[+] Setting Up Rust"
curl -sSLk https://sh.rustup.rs -o /tmp/rustup.sh
echo '#!/usr/bin/expect -f
set timeout -1
spawn /tmp/rustup.sh
send -- "1\r"
expect eof' > /tmp/rustup.exp
chmod +x /tmp/rustup.*
/tmp/rustup.exp ; 
source $HOME/.cargo/env
rm -f /tmp/rustup.*
echo "[+] Setting up NodeJS"
sudo npm i -g n
sudo n 14.18
echo "[+] Installed NodeJS $(node -v) & NPM $(npm -v)"
sudo npm i -g pm2 yarn || exit 1
echo "[+] Installed pm2 & yarn (latest)"

## CleanUp ##
[[ ${CLEANUP} == "true" ]] && {
	echo "[+] Removing ${SPACE} as Cleanup was selected"
	rm -rf ${SPACE}/*
}

## setup_telemetry ##
APPNAME="substrate-telemetry"
GITURL="https://github.com/Axia-Tech/substrate-telemetry"
echo "[+] Bringing code from ${GITURL}"
[[ -d "${SPACE}/${APPNAME}" ]] || { sudo mkdir -p ${SPACE}/${APPNAME} ; sudo chown -R $(whoami).$(whoami) ${SPACE} ; }
cd ${SPACE}/${APPNAME} ; git init ; git remote add origin ${GITURL} ; git remote update ; git reset --hard
git checkout ${BRANCH} ; git pull origin ${BRANCH}
cd "${SPACE}/${APPNAME}/backend"
cargo build --release || exit 1
cd "${SPACE}/${APPNAME}/frontend"
yarn install || exit 1
sleep 1

## Frontend Patching ## Module to be Fixed by DevTeam ##
## Patch 1
cd "${SPACE}/${APPNAME}/frontend"
ERR1="$(grep -Rin '\...options' node_modules/camelcase/index.js)"
[[ ! -z "${ERR1}" ]] && sed -i -e '62,65d' node_modules/camelcase/index.js && sed -i 's|options = {|options = {};|g' node_modules/camelcase/index.js
## End Patch 1

## setup_telemetry_exporter ##
APPNAME="substrate-telemetry-exporter"
GITURL="https://github.com/Axia-Tech/substrate-telemetry-exporter"
echo "[+] Bringing code from ${GITURL}"
[[ -d "${SPACE}/${APPNAME}" ]] || { sudo mkdir -p ${SPACE}/${APPNAME} ; sudo chown -R $(whoami).$(whoami) ${SPACE} ; }
cd ${SPACE}/${APPNAME} ; git init ; git remote add origin ${GITURL} ; git remote update ; git reset --hard
git checkout ${BRANCH} ; git pull origin ${BRANCH}
yarn install || exit 1
sleep 1

## Starting Telemetry Stack
bash /opt/opsdude/axia-utils/operate/start.telemetry.sh

## E O F ##