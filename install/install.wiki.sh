#!/bin/bash
# Author : Abhishek Rana
# Description : Script to configure AXIA apps on fresh machine

SPACE="/home/AXIA"
APPNAME="wiki"
GITURL="https://github.com/Axia-Tech/AXIA-wiki.git"

BRANCH="$1" ; [[ -z ${BRANCH} ]] && BRANCH="master"
CLEANUP="$2" ; [[ -z ${CLEANUP} ]] && CLEANUP="false"

check_pkgs(){
	which npm || {
		echo "[+] Well, It's a fresh Node, Setting up from scratch."
		sudo apt install npm jq net-tools git curl libssl-dev libffi-dev -y 
		sudo npm i -g n
		sudo n 14.18
		echo "[+] Installed NodeJS $(node -v) & NPM $(npm -v)"
		sudo npm i -g pm2 yarn || exit 1
		echo "[+] Installed pm2 & yarn (latest)"
	}
}

cleanup(){
	[[ ${CLEANUP} == "true" ]] && {
		echo "[+] Removing ${SPACE}/${APPNAME} as Cleanup was selected"
		cd ${SPACE}/${APPNAME}
		PROCNAME="$(pwd|rev| cut -d '/' -f1-2|rev| sed 's/\//-/g')"
		pm2 status ; sleep 3
		pm2 stop ${PROCNAME}
		pm2 delete ${PROCNAME}
		cd ${SPACE}
		rm -rf ${SPACE}/${APPNAME}
	}
}

setup_app(){
	echo "[+] Bringing code from ${GITURL}"
	[[ -d "${SPACE}/${APPNAME}" ]] || { sudo mkdir -p ${SPACE}/${APPNAME} ; sudo chown -R $(whoami).$(whoami) ${SPACE} ; }
	cd ${SPACE}/${APPNAME} ; git init ; git remote add origin ${GITURL} ; git remote update ; git reset --hard
	git checkout ${BRANCH} ; git pull origin ${BRANCH}
	yarn install || exit 1
	sleep 1
}

patching(){
	# Well You know Dev Team is working on many things. Therefore, Code stability is ideal & According to them. We need to automate the manual patching work as well.
	cd ${SPACE}/${APPNAME}

	# End of Patching #
}

start_app(){
	echo "[+] Starting App ${APPNAME}"
	# pm2 start yarn --name ${APPNAME} -- start
	PM2="/usr/local/bin/pm2"
	${PM2} status ; sleep 3
	cd ${SPACE}/${APPNAME}
	PROCNAME="$(pwd|rev| cut -d '/' -f1-2|rev| sed 's/\//-/g')"
	SID="$("${PM2}" id "${PROCNAME}"| sed -e 's| ||g' -e 's|\[||g' -e 's|\]||g')"
	[[ -z "${SID}" ]] && "${PM2}" start yarn --name ${PROCNAME} -- start  || "${PM2}" restart "${SID}"
	"${PM2}" save
}

## Mains ##

check_pkgs
cleanup
setup_app
patching
start_app

## E O F ##
