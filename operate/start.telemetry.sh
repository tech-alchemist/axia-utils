#!/bin/bash
## Author : Abhishek Rana ##
## Description : Script to Start Full Node ##

SPACE="/home/AXIA"
LOGDIR="${SPACE}/Data/Logs"
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
./target/release/telemetry_core  -l 0.0.0.0:8000 &> ${LOGDIR}/telemetry.core.log &
sleep 2
./target/release/telemetry_shard -l 0.0.0.0:8001 &> ${LOGDIR}/telemetry.shard.log &
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