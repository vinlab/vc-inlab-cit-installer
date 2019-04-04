#!/bin/sh
#
# Install Code Inventory
#
# Enable installing from a curl command
#
# For example
# curl -fsS https://codeinventory.com/install | bash
#
# Author: Andrey Potekhin

prompt() {
	echo "$1"
	if [ -n "$2" ]; then
		read -p "$2" -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			exit 1
		fi
	fi
}

command_exist() {
	type "$@" &> /dev/null
}

startup_prompt() {
	prompt "
	Welcome to Code Inventory install!

	Please make sure you have the following:"

	prompt "
	Access requirements:

	- Docker Hub account https://hub.docker.com
	- Access to our Vinlab org private repos at Docker Hub
		- For example, you have received and accepted an invitation to *enduser* team at Vinlab org" "
	I do have these (y/N) "

	prompt "
	OS requirements:

	- OS X 10.x or higher" "
	Yep, that's my case (y/N) "

	prompt "
	Software requirements:

	- Docker
	- Docker-compose (installed as part of Docker on OS X)
	- Docker engine is running in Swarm mode
		- For example, you have ran 'docker swarm init' (or 'docker swarm join') at least once
		- This is required for encryption
	- You are logged in to Docker Hub
		- This is required for pulling Code Inventory's docker images

	(If you are not sure about any of these, please consult Code Inventory documentation!)" "
	I do have all these, let's go (y/N) "
}

require_docker() {
	if ! command_exist docker; then
      echo 'CHECKING IF DOCKER COMMAND IS AVAILABLE>' >&2
	  echo 'Docker command not found, you need to install Docker first. Exiting.' >&2
	  exit 1
	fi
	if ! command_exist docker-compose; then
      echo 'CHECKING IF DOCKER COMPOSE COMMAND IS AVAILABLE>' >&2
	  echo 'Docker-compose command not found, exiting.' >&2
	  exit 1
	fi
}

require_docker_swarm() {
	if [ -z "`docker info | grep -F 'Swarm:'`" ]; then
      echo 'CHECKING IF DOCKER SWARM IS AVAILABLE>' >&2
	  echo 'Docker swarm not found. Use "docker swarm init" to create a single-node swarm (or "docker swarm join" to connect to existing swarm.)' >&2
	  exit 1
	fi
	if [ -z "`docker info | grep -F 'Swarm: active'`" ]; then
      echo 'CHECKING IF DOCKER SWARM IS ACTIVE>' >&2
	  echo 'Docker swarm not active. Use "docker swarm init" to activate a single-node swarm (or "docker swarm join" to connect to existing swarm.)' >&2
	  exit 1
	fi
	if ! docker node ls &> /dev/null; then
      echo 'CHECKING WHETHER THIS NODE IS PART OF DOCKER SWARM>' >&2
      docker node ls  >&2
	  echo 'This node is not a swarm manager. Use "docker swarm init" to create a single-node swarm (or "docker swarm join" to connect to existing swarm.)' >&2
	  exit 1
	fi
}

require_docker_login() {
	return
# TODO
}

require_master_password() {
	if ! docker secret ls | grep -w 'code-inventory-master-password'; then
      echo 'CHECKING IF MASTER PASSWORD EXISTS>' >&2
	  echo 'Master password not found, please re-run the install script.' >&2
	  exit 1
	fi
}

verify_master_password() {
	if ! docker secret ls | grep -w 'code-inventory-master-password' &> /dev/null; then
      echo 'VERIFYING MASTER PASSWORD>' >&2
	  echo 'Master password not found, exiting.' >&2
	  exit 1
	fi
}

startup_sequence(){
	require_docker
	require_docker_swarm
	require_docker_login
	# TODO: check if CIT is already running, prompt to stop
}

exit_sequence(){
	verify_master_password
	# TODO: verify_other_docker_secrets
	# TODO: verify_installed_files
}

create_master_password(){
	# Check if master password already exists, prompt to keep/overwrite
	already_exists=false
	want_to_overwrite=false
	if docker secret ls | grep -w 'code-inventory-master-password'; then
		already_exists=true
		read -p 'Master password already exist, do you want to overwrite (not recommended)? (y/n) ' -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			want_to_overwrite=true
		fi
	fi
	if ! $already_exists || $want_to_overwrite; then
		# Prompt for master password
		read -p 'Create master password, for encryption purposes: ' -r -s
		master_password=$REPLY
		read -p 'Confirm master password: ' -r -s
		master_password_confirmation=$REPLY
		if [ $master_password -ne $master_password_confirmation ]; then
			echo "Passwords do not match, please retry"
			#TODO: implement retrying password entry
			verify_master_password
		fi
		# Remove master password docker secret, if any
		if $already_exists; then
			echo 'REMOVING MASTER PASSWORD DOCKER SECRET>'
			if ! docker secret rm code-inventory-master-password; then
				echo 'Failed to remove master password docker secret, exiting' >&2
				exit 1
			fi
			# Verify the secret was removed
			if docker secret ls | grep -w 'code-inventory-master-password'; then
				echo 'Failed to remove master password docker secret, exiting' >&2
				exit 1
			fi
		fi
		# Save master password into a docker secret
		echo 'CREATING MASTER PASSWORD>'
		if ! echo $master_password | docker secret create code-inventory-master-password -; then
				echo 'Failed to create master password docker secret, exiting' >&2
				exit 1
		fi
		echo 'CREATING MASTER PASSWORD>DONE'
	fi
	verify_master_password
}

FROM_DIR=`pwd`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${DIR}

startup_prompt
echo 'CHECKING SETUP PREREQUISITES>'
startup_sequence
echo 'CHECKING SETUP PREREQUISITES>DONE'

echo 'CHECKING IF CODE INVENTORY IS ALREADY INSTALLED>'
echo "    TODO: check for CIT is already installed, prompt to proceed with overwrite"
echo 'CHECKING IF CODE INVENTORY IS ALREADY INSTALLED>DONE'

echo 'DOWNLOADING CODE INVENTORY ASSEMBLY SCRIPTS>'
echo "    TODO: Download CIT Assembly archive/tgz to /tmp"
echo "    TODO: Unpack tgz to ~/veracode/code-inventory/bin"
echo "    TODO: Remove CIT Assembly archive from /tmp"
echo 'DOWNLOADING CODE INVENTORY ASSEMBLY SCRIPTS>DONE'

echo 'CREATING MASTER PASSWORD>'
create_master_password
echo 'CREATING MASTER PASSWORD>DONE'

echo 'CREATING DOCKER SECRETS>'
echo "    TODO: Save backend user/password to docker secret"
echo "    TODO: Save grafana user/password to docker secret"
echo "    TODO: Save postgres password to docker secret"
echo 'CREATING DOCKER SECRETS>DONE'

exit_sequence
cd ${FROM_DIR}
