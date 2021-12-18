#!/bin/bash
# Author : Tech-Alchemist (Abhishek Rana)
# Description : Script to configure AXIA Full Node

SPACE="/home/AXIA"
APPNAME="Bins"
RELEASE_URL="https://releases.axiacoin.network/TestNet/axia"


install_rust(){
sudo apt-get update
sudo apt-get install -y git clang curl libssl-dev llvm libudev-dev expect net-tools wget
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
}

get_binary(){
[[ -d "${SPACE}/${APPNAME}" ]] || { sudo mkdir -p ${SPACE}/${APPNAME} ; sudo chown -R $(whoami).$(whoami) ${SPACE} ; }
cd ${SPACE}/${APPNAME}
wget -c ${RELEASE_URL} ; chmod +x axia
}

install_rust
get_binary

## E O F ##