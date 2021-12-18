#!/bin/bash
# Author : Tech-Alchemist (Abhishek Rana)
# Description : Script to configure AXIA Telemetry on fresh Machine

SPACE="/home/AXIA"
LOGDIR="${SPACE}/Data/Logs"
BRANCH="master"
CLEANUP="$1" ; [[ -z ${CLEANUP} ]] && CLEANUP="false"
PM2="/usr/local/bin/pm2"

## Install required packages ##
which npm || {
	echo "[+] Well, It's a fresh Node, Setting up from scratch."
	sudo apt install npm jq net-tools git curl libssl-dev libffi-dev clang llvm libudev-dev expect wget
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
}

## CleanUp ##
[[ ${CLEANUP} == "true" ]] && {
	echo "[+] Removing ${SPACE} as Cleanup was selected"
	cd ${SPACE}
	rm -rf *
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

## setup_telemetry_exporter ##
APPNAME="substrate-telemetry-exporter"
GITURL="https://github.com/Axia-Tech/substrate-telemetry-exporter"
echo "[+] Bringing code from ${GITURL}"
[[ -d "${SPACE}/${APPNAME}" ]] || { sudo mkdir -p ${SPACE}/${APPNAME} ; sudo chown -R $(whoami).$(whoami) ${SPACE} ; }
cd ${SPACE}/${APPNAME} ; git init ; git remote add origin ${GITURL} ; git remote update ; git reset --hard
git checkout ${BRANCH} ; git pull origin ${BRANCH}
yarn install || exit 1
sleep 1

## patching
cd ${SPACE}/${APPNAME}

## start_telemetry
APPNAME="substrate-telemetry"
mkdir -p ${LOGDIR}
cd "${SPACE}/${APPNAME}/backend"
./target/release/telemetry_core  -l 0.0.0.0:8000 &> "${LOGDIR}/telemetry.core.log"  &
./target/release/telemetry_shard -l 0.0.0.0:8001 &> "${LOGDIR}/telemetry.shard.log" &
cd "${SPACE}/${APPNAME}/frontend"
echo "[+] Starting App ${APPNAME}"
${PM2} status ; sleep 3
PROCNAME="$(pwd|rev| cut -d '/' -f1-2|rev| sed 's/\//-/g')"
SID="$("${PM2}" id "${PROCNAME}"| sed -e 's| ||g' -e 's|\[||g' -e 's|\]||g')"
[[ -z "${SID}" ]] && "${PM2}" start yarn --name ${PROCNAME} -- start  || "${PM2}" restart "${SID}"
sleep 1
"${PM2}" save

## start_telemetry_exporter
APPNAME="substrate-telemetry-exporter"
echo "[+] Starting App ${APPNAME}"
${PM2} status ; sleep 3
cd ${SPACE}/${APPNAME}
PROCNAME="$(pwd|rev| cut -d '/' -f1-2|rev| sed 's/\//-/g')"
SID="$("${PM2}" id "${PROCNAME}"| sed -e 's| ||g' -e 's|\[||g' -e 's|\]||g')"
[[ -z "${SID}" ]] && "${PM2}" start yarn --name ${PROCNAME} -- start  || "${PM2}" restart "${SID}"
sleep 1
"${PM2}" save

## E O F ##