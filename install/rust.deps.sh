#!/bin/bash
# Author : Tech-Alchemist (Abhishek Rana)
# Description : Script to Install Rust Deps Before Starting Node

echo "[+] Installing dependencies required by Rust based Binaries"
sudo apt-get update
sudo apt-get install -y npm jq net-tools git curl libssl-dev libffi-dev clang llvm libudev-dev expect wget librust-openssl-dev python3 python3-dev python3-pip
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
echo "[+] Installed $(rust -V) and $(cargo -V)"
## E O F ##