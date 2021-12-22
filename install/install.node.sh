#!/bin/bash
# Author : Tech-Alchemist (Abhishek Rana)
# Description : Script to configure AXIA Full Node

SPACE="/home/AXIA"
RELEASE_URL="https://releases.axiacoin.network/TestNet/axia"

install_rust(){
sudo apt-get update
sudo apt-get install -y git clang curl libssl-dev llvm libudev-dev expect net-tools wget librust-openssl-dev python3-dev python3 python3-pip
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
[[ -d "${SPACE}/Bins" ]] || { sudo mkdir -p ${SPACE}/Bins ; sudo chown -R $(whoami).$(whoami) ${SPACE} ; }
cd ${SPACE}/Bins
wget -c ${RELEASE_URL} ; chmod +x axia
}

install_rust
get_binary

## E O F ##