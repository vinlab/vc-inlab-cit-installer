#!/bin/sh

# Install Code Inventory.
command_exist() {
	type "$@" &> /dev/null
}

require_docker() {
	if ! command_exist docker; then
	  echo 'Docker command not found, aborting' >&2
	  exit 1
	fi
	
	if ! command_exist docker-compose; then
	  echo 'Docker-compose command not found, aborting' >&2
	  exit 1
	fi
}

common_init(){
	require_docker;
}

FROM_DIR=`pwd`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${DIR}
common_init
echo "TODO: check for docker swarm availability, required for docker secrets"
echo "TODO: check for CIT Assembly already installed, prompt to proceed"
echo "TODO: pull CIT Assembly tgz"
echo "TODO: Unpack tgz to ~/veracode/code-inventory/bin"
echo "TODO: Check if master password exists, prompt to keep/overwrite"
echo "TODO: Prompt for master password"
echo "TODO: Save master password in a docker secret"
echo "TODO: Save backend user/password in a docker secret"
echo "TODO: Save grafana user/password in a docker secret"
cd ${FROM_DIR}
