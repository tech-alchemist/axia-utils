#!/bin/bash
## Author : Abhishek Rana ##
## Description : Script to Start Standard AXIA Node ##

P2P="3101"
WSS="3102"
RPC="3103"
SPACE="/home/AXIA"
BINARY="${SPACE}/Bins/axia"
DATADIR="${SPACE}/Data/NodeData"
LOGFILE="${SPACE}/Data/daemon.log"
NETWORK="$1" ; [[ -z ${NETWORK} ]] && { echo "[-] Usage : $0 <testnet|canarynet|mainnet >" ; exit 1 ; }

NODENAME="${NETWORK} $(ifconfig | grep "^e\|^w" -A 4| grep ether| awk '{print $2}' | sed 's|:| |g' | rev | head -1)"

get_raw_file()
{
RAWFILEURL="$1"
rm -f ${SCAPE}/Data/${NETWORK}.raw.json
wget -c "${RAWFILEURL}" -O ${SPACE}/Data/${NETWORK}.raw.json || { echo "[-] Error : File not found at URL : ${RAWFIELURL}" ; exit 1 ; }
}

start_network(){
    NETNAME="$1"
    for i in $(ps aux | grep ${BINARY}| grep "NodeData" | awk '{print $2}'); do kill -9 $i; done && sleep 3
    mkdir -p ${DATADIR}
    [[ -f "${SPACE}/Data/${NETNAME}.raw.json" ]] && CHAINNAME="${SPACE}/Data/${NETNAME}.raw.json" || CHAINNAME="alphanet"
    ${BINARY} -d ${DATADIR} --ws-port ${WSS} --rpc-port ${RPC} --port ${P2P} --chain ${SPACE}/Data/${NETNAME}.raw.json --rpc-cors all --unsafe-rpc-external --unsafe-ws-external --name "${NODENAME}" &> "${LOGFILE}" &
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
    get_raw_file "https://releases.axiacoin.network/TestNet/testnet.raw.json"
    start_network mainnet
    ;;

  CanaryNet | CANARYNET | canarynet)
    get_raw_file "https://releases.axiacoin.network/TestNet/testnet.raw.json"
    start_network canarynet
    ;;

  TestNet | TESTNET | testnet)
    get_raw_file "https://releases.axiacoin.network/TestNet/testnet.raw.json"
    start_network testnet
    ;;

  *)
    echo -n "[-] Unknown Network Type"
    ;;

esac

## E O F ##