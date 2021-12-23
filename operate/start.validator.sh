#!/bin/bash
# Author : Tech-Alchemist (Abhishek Rana)
## Description : Script to Start AXIA Validator Node ## Make Sure to Insert keys before starting this script ##
## Usage : ./this_script < testnet | canarynet | mainnet >

P2P="3101"
WSS="3102"
RPC="3103"
SPACE="/home/AXIA"
BINARY="${SPACE}/Bins/axia"
DATADIR="${SPACE}/Data/NodeData"
LOGFILE="${SPACE}/Data/daemon.log"
HELPMSG="[-] Usage : $0 < testnet | canarynet | mainnet >"
NETWORK="$1" ; [[ -z ${NETWORK} ]] && { echo "${HELPMSG}" ; exit 1 ; }

## Check Required Packages ##
which rustc  || { bash /opt/opsdude/axia-utils/install/rust.deps.sh ; }
which cargo  || { bash /opt/opsdude/axia-utils/install/rust.deps.sh ; }

## Unqiue Node Name for Telemetry ##
NODENAME="${NETWORK^} Validator $(ifconfig | grep "^e\|^w" -A 4| grep ether| awk '{print $2}' | sed 's|:| |g' | rev | head -1)"

## Check File Sanity & Bring If file is not correct ##
file_sanity(){
  FILE_PATH="$1"
  FILE_NAME="$2"
  FILE_URL="$3"
  CHECKSUM_URL="https://releases.axiacoin.network/stable/checksums.txt"
  CHECKSUM_FILE="/tmp/.checksum.txt"
  rm -f ${CHECKSUM_FILE} ; wget -c "${CHECKSUM_URL}" -q -O ${CHECKSUM_FILE} || { echo "[-] Unable to downlaod checksums from ${CHECKSUM_URL}"  ; exit 1 ; }  MENTIONED_HASH="$(grep -i " ${FILE_NAME}" ${CHECKSUM_FILE}|awk '{print $1}'| head -1)"
  EXISTING_HASH="$(md5sum ${FILE_PATH} | awk '{print $1}')"
  [[ "${MENTIONED_HASH}" != "${EXISTING_HASH}" ]] && { 
    rm -f ${FILE_PATH}
    sudo mkdir -p ${SPACE}/Bins ${DATADIR} ; sudo chown -R $(whoami).$(whoami) ${SPACE}
    echo "[-]  File = [${FILE_NAME}] is InValid. Downloading..."
    wget -c "${FILE_URL}" -q --show-progress -O ${FILE_PATH} || { echo "[-] Unable to download ${FILE_PATH} from ${FILE_URL}" ; exit 1 ; }
    chmod +x ${FILE_PATH}
  } || echo "[+] File = [${FILE_NAME}] is valid."
}

## Start Network Accordingly
start_network(){
    NETNAME="$1"
    for i in $(ps aux | grep ${BINARY}| grep "NodeData" | awk '{print $2}'); do kill -9 $i && echo "[+] Killed Existing PID ${i}"; done && sleep 3
    mkdir -p ${DATADIR}
    [[ -f "${SPACE}/Data/${NETNAME}.raw.json" ]] && CHAINNAME="${SPACE}/Data/${NETNAME}.raw.json" || { echo "[-] Invalid ChainSpec" ; exit 1 ; }
    ${BINARY} -d ${DATADIR} --ws-port ${WSS} --rpc-port ${RPC} --port ${P2P} --chain ${SPACE}/Data/${NETNAME}.raw.json --rpc-cors all --unsafe-rpc-external --unsafe-ws-external --name "${NODENAME}" --validator &> "${LOGFILE}" &
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
    file_sanity "${SPACE}/Bins/axia"                    "axia"                    "releases.axiacoin.network/stable/axia"
    file_sanity "${SPACE}/Data/${NETWORK,,}.raw.json"   "${NETWORK,,}.raw.json"   "releases.axiacoin.network/stable/testnet.raw.json"
    start_network ${NETWORK,,}
    ;;

  CanaryNet | CANARYNET | canarynet)
    file_sanity "${SPACE}/Bins/axia"                    "axia"                    "releases.axiacoin.network/stable/axia"
    file_sanity "${SPACE}/Data/${NETWORK,,}.raw.json"   "${NETWORK,,}.raw.json"   "releases.axiacoin.network/stable/${NETWORK,,}.raw.json"
    start_network ${NETWORK,,}
    ;;

  TestNet | TESTNET | testnet)
    file_sanity "${SPACE}/Bins/axia"                    "axia"                    "https://releases.axiacoin.network/stable/axia"
    file_sanity "${SPACE}/Data/${NETWORK,,}.raw.json"   "${NETWORK,,}.raw.json"   "https://releases.axiacoin.network/stable/${NETWORK,,}.raw.json"
    start_network ${NETWORK,,}
    ;;

  *)
    echo -n "[-] Unknown Network Type"
    echo "${HELPMSG}"
    exit 1
    ;;

esac

## E O F ##