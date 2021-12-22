#!/bin/bash
# Author : Tech-Alchemist (Abhishek Rana)
# Description : Script to Install AXIA Telemetry on fresh Machine

SPACE="/home/AXIA"
LOGDIR="${SPACE}/Data/Logs"
BRANCH="$1" ; [[ -z ${BRANCH} ]] && BRANCH="master"
CLEANUP="$2" ; [[ -z ${CLEANUP} ]] && CLEANUP="false"

## Check Required Packages ##
which npm  || { bash /opt/opsdude/axia-utils/install/js.deps.sh ; }
which pm2  || { bash /opt/opsdude/axia-utils/install/js.deps.sh ; }
which yarn || { bash /opt/opsdude/axia-utils/install/js.deps.sh ; }
which rustc  || { bash /opt/opsdude/axia-utils/install/rust.deps.sh ; }
which cargo  || { bash /opt/opsdude/axia-utils/install/rust.deps.sh ; }

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
echo "[+] Backend Compiled"
cd "${SPACE}/${APPNAME}/frontend"
yarn install || exit 1
echo "[+] Frontend Compiled"
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
echo "[+] Exporter Compiled"
sleep 1

## Starting Telemetry Full Stack

mkdir -p ${LOGDIR} &> /dev/null
PM2="/usr/local/bin/pm2"

## start substrate_telemetry
APPNAME="substrate-telemetry"
echo "[+] Killing Old Backend Processes"
for i in $(lsof -i:8000 | awk '{print $2}'| sed '/^PID/d'| uniq); do kill -9 $i; done 
for i in $(lsof -i:8001 | awk '{print $2}'| sed '/^PID/d'| uniq); do kill -9 $i; done
sleep 2
echo "[+] Starting Backend"
cd ${SPACE}/${APPNAME}/backend
bash -c "/home/AXIA/substrate-telemetry/backend/target/release/telemetry_core  -l 0.0.0.0:8000 &> /home/AXIA/Data/Logs/telemetry.core.log  &" &> /dev/null
sleep 2
bash -c "/home/AXIA/substrate-telemetry/backend/target/release/telemetry_shard -l 0.0.0.0:8001 &> /home/AXIA/Data/Logs/telemetry.shard.log &" &> /dev/null
sleep 2
cd ${SPACE}/${APPNAME}/frontend
echo "[+] Starting Frontend ${APPNAME}"
${PM2} status ; sleep 3
PROCNAME="$(pwd|rev| cut -d '/' -f1-2|rev| sed 's/\//-/g')"
SID="$("${PM2}" id "${PROCNAME}"| sed -e 's| ||g' -e 's|\[||g' -e 's|\]||g')"
[[ -z "${SID}" ]] && "${PM2}" start yarn --name ${PROCNAME} -- start  || "${PM2}" restart "${SID}"
sleep 2

##  start substrate_telemetry_exporter
APPNAME="substrate-telemetry-exporter"
echo "[+] Starting Exporter ${APPNAME}"
${PM2} status ; sleep 3
cd ${SPACE}/${APPNAME}
PROCNAME="$(pwd|rev| cut -d '/' -f1-2|rev| sed 's/\//-/g')"
SID="$("${PM2}" id "${PROCNAME}"| sed -e 's| ||g' -e 's|\[||g' -e 's|\]||g')"
[[ -z "${SID}" ]] && "${PM2}" start yarn --name ${PROCNAME} -- start  || "${PM2}" restart "${SID}"
sleep 2
"${PM2}" save

## E O F ##