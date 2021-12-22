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
HELPMSG="[-] Usage : $0 < testnet | canarynet | mainnet >"
NETWORK="$1" ; [[ -z ${NETWORK} ]] && { echo "${HELPMSG}" ; exit 1 ; }

## Unqiue Node Name 
NODENAME="${NETWORK^} Node $(ifconfig | grep "^e\|^w" -A 4| grep ether| awk '{print $2}' | sed 's|:| |g' | rev | head -1)"

## Check File Sanity & Bring If file is 
file_sanity(){
  FILE_PATH="$1"
  FILE_NAME="$2"
  FILE_URL="$3"
  CHECKSUM_FILE="/opt/opsdude/axia-utils/extras/checksum.txt"
  MENTIONED_HASH=$(grep -i " ${FILE_NAME}" ${CHECKSUM_FILE}|sed 's/ */ /g'|awk '{print $1}'| head -1)
  EXISTING_HASH=$(md5sum ${FILE_PATH}|awk '{print $1}')
  [[ "${MENTIONED_HASH}" != "${EXISTING_HASH}" ]] && { 
    rm -f ${FILE_PATH}
    sudo mkdir -p ${SPACE}/Bins ${DATADIR} ; sudo chown -R $(whoami).$(whoami) ${SPACE}
    wget -c "${FILE_URL}" -q --show-progress -O ${FILE_PATH} || { echo "[-] Unable to download ${FILE_PATH} from ${FILE_URL}" ; exit 1 ; }
  } || echo "[+] File [${FILE_NAME}] has valid hash [${EXISTING_HASH}] , Skipping downlaod.."
}

## Start Network Accordingly
start_network(){
    NETNAME="$1"
    for i in $(ps aux | grep ${BINARY}| grep "NodeData" | awk '{print $2}'); do kill -9 $i; done && sleep 3
    mkdir -p ${DATADIR}
    [[ -f "${SPACE}/Data/${NETNAME}.raw.json" ]] && CHAINNAME="${SPACE}/Data/${NETNAME}.raw.json" || CHAINNAME="alphanet"
    ${BINARY} -d ${DATADIR} --ws-port ${WSS} --rpc-port ${RPC} --port ${P2P} --chain ${SPACE}/Data/${NETNAME}.raw.json --rpc-cors all --unsafe-rpc-external --unsafe-ws-external --name "${NODENAME}" --pruning archive --wasm-execution Compiled &> "${LOGFILE}" &
    echo "[+] Node started with :"
    echo "    Ports    : P2P = ${P2P} , WSS = ${WSS} , RPC = ${RPC}"
    echo "    Log File : ${LOGFILE}"
    sleep 10
    BOOTID="$(grep -i "Local node identity is:" ${SPACE}/Data/daemon.log | tail -n 1 | cut -d ':' -f4 | sed 's/ //g')"
    PRIVIP="$(ifconfig | grep "^e" -A1| tail -n 1 |awk '{print $2}')"
    echo "    BOOTNODE : /ip4/${PRIVIP}/tcp/${P2P}/p2p/${BOOTID}"
}

case $NETWORK in

  MainNet | MAINNET | mainnet)
    file_sanity "${SPACE}/Bins/axia" "axia" "https://releases.axiacoin.network/TestNet/axia"
    file_sanity "${SPACE}/Data/NodeData/testnet.raw.json" "testnet.raw.json" "https://releases.axiacoin.network/TestNet/testnet.raw.json"
    start_network testnet
    ;;

  CanaryNet | CANARYNET | canarynet)
    file_sanity "${SPACE}/Bins/axia" "axia" "releases.axiacoin.network/TestNet/axia"
    file_sanity "${SPACE}/Data/NodeData/canarynet.raw.json" "canarynet.raw.json" "https://releases.axiacoin.network/CanaryNet/canarynet.raw.json"
    start_network canarynet
    ;;

  TestNet | TESTNET | testnet)
    file_sanity "${SPACE}/Bins/axia" "axia" "https://releases.axiacoin.network/TestNet/axia"
    file_sanity "${SPACE}/Data/NodeData/testnet.raw.json" "testnet.raw.json" "https://releases.axiacoin.network/TestNet/testnet.raw.json"
    start_network testnet
    ;;

  *)
    echo -n "[-] Unknown Network Type"
    echo "${HELPMSG}"
    exit 1
    ;;

esac

## E O F ##