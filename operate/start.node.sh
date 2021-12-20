#!/bin/bash
## Author : Abhishek Rana ##
## Description : Script to Start Standard AXIA Node ##

P2P="3101"
WSS="3102"
RPC="3103"

SPACE="/home/AXIA"
BINARY="${SPACE}/Bins/axia"
DATADIR="${SPACE}/Data/NodeData"
NODENAME="$(hostname)"
LOGFILE="${SPACE}/Data/daemon.log"

NETWORK="$1" ; [[ -z ${NETWORK} ]] && { echo "[-] Usage : $0 <testnet|canarynet|mainnet >" ; exit 1 ; }

start_network(){
    NETNAME="$1"
    for i in $(ps aux | grep ${BINARY}| grep "NodeData" | awk '{print $2}'); do kill -9 $i; done && sleep 3
    mkdir -p ${DATADIR}
    ${BINARY} -d ${DATADIR} --ws-port ${WSS} --rpc-port ${RPC} --port ${P2P} --chain ${NETNAME} --rpc-cors all --unsafe-rpc-external --unsafe-ws-external --name "${NODENAME}" &> "${LOGFILE}" &
    echo "[+] Node started with :"
    echo "    Ports    : P2P = ${P2P} , WSS = ${WSS} , RPC = ${RPC}"
    echo "    Log File : ${LOGFILE}"
    sleep 5
    BOOTID="$(grep -i "Local node identity is:" ${SPACE}/Data/daemon.log | tail -n 1 | cut -d ':' -f4 | sed 's/ //g')"
    PRIVIP="$(ifconfig | grep "^e" -A1| tail -n 1 |awk '{print $2}')"
    echo "    BOOTNODE : /ip4/${PRIVIP}/tcp/${P2P}/p2p/${BOOTID}"
}

case $NETWORK in

  MainNet | MAINNET | mainnet)
    start_network axia
    ;;

  CanaryNet | CANARYNET | canarynet)
    start_network canarynet
    ;;

  TestNet | TESTNET | testnet)
    start_network alphanet
    ;;

  *)
    echo -n "[-] Unknown Network Type"
    ;;

esac

## E O F ##