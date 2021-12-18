#!/bin/bash
## Author : Abhishek Rana ##
## Description : Script to Start Full Node ##

P2P="3101"
WSS="3102"
RPC="3103"

SPACE="/home/AXIA"
BINARY="${SPACE}/Bins/axia"
DATADIR="${SPACE}/Data/NodeData"
KEYSTOR="${SPACE}/Data/KeyStore"

BOOTNODES="/ip4/10.0.7.77/tcp/3101/p2p/12D3KooWCLMg1iYgpZyHnXvvNyzEFJNbosccdkj9zxmdEfvFvGeT"

for i in $(ps axu | grep ${BINARY}| grep "NodeData" | awk '{print $2}'); do kill -9 $i; done && sleep 3
mkdir -p ${DATADIR} ${DATADIR}
${BINARY} -d ${DATADIR} --keystore-path ${KEYSTOR} --ws-port ${WSS} --rpc-port ${RPC} --port ${P2P} \
    --rpc-cors all  --unsafe-rpc-external --unsafe-ws-external --bootnodes ${BOOTNODES} 
    --allow-private-ipv4 &> "${SPACE}/Data/daemon.log" &
echo "[+] Node started with Log => ${SPACE}/Data/daemon.log"
sleep 4
BOOTID="$(grep -i "Local node identity is:" ${SPACE}/Data/daemon.log | tail -n 1 | cut -d ':' -f4 | sed 's/ //g')"
PRIVIP="$(ifconfig | grep "^e" -A1| tail -n 1 |awk '{print $2}')"
echo "BOOTNODE => /ip4/${PRIVIP}/tcp/${P2P}/p2p/${BOOTID}"

## E O F ##