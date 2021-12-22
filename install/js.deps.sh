#!/bin/bash
# Author : Tech-Alchemist (Abhishek Rana)
# Description : Script to Install JS Deps Before Starting JS based Apps

echo "[+] Installing dependencies required by JS based Apps & Extensions"
sudo apt install npm jq net-tools git curl libssl-dev libffi-dev -y 
sudo npm i -g n
sudo n 14.18
echo "[+] Installed NodeJS $(node -v) & NPM $(npm -v)"
sudo npm i -g pm2 yarn || exit 1
echo "[+] Installed pm2 & yarn (latest)"

## E O F ##
