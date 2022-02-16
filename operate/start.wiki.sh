#!/bin/bash
# Author : Abhishek Rana
# Description : Script to configure AXIA Common Wiki on fresh machine

SPACE="/home/AXIA"
APPNAME="wiki"
GITURL="https://github.com/Axia-Tech/AXIA-wiki.git"

BRANCH="$1" ; [[ -z ${BRANCH} ]] && BRANCH="master"
CLEANUP="$2" ; [[ -z ${CLEANUP} ]] && CLEANUP="false"

## Check Required Packages ##
which npm  || { bash /opt/opsdude/axia-utils/install/js.deps.sh ; }
which pm2  || { bash /opt/opsdude/axia-utils/install/js.deps.sh ; }
which yarn || { bash /opt/opsdude/axia-utils/install/js.deps.sh ; }

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
	sleep 2
	# Color Change in https://wiki.axiacoin.network/docs/build-pdk
	cd ${SPACE}/${APPNAME}
	sed -i 's|#d73a49|#136197|g' node_modules/prism-react-renderer/themes/github/index.cjs.js
	sed -i 's|#e3116c|#303030|g' node_modules/prism-react-renderer/themes/github/index.cjs.js
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

cleanup
setup_app
patching
start_app

## E O F ##
