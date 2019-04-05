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

prompt_yN() {
	if [ -n "$2" ]; then
		echo "$1"
		read -p "$2" -n 1 -r
	else
		read -p "$1" -n 1 -r
	fi
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		true
		return
	fi
	false
}

prompt_Yn() {
	if [ -n "$2" ]; then
		echo "$1"
		read -p "$2" -n 1 -r
	else
		read -p "$1" -n 1 -r
	fi
	echo
	if [[ $REPLY =~ ^[Nn]$ ]]; then
		false
		return
	fi
	true
}

command_exists() {
	type "$@" &> /dev/null
}

startup_prompt() {
	prompt "
	Welcome to Code Inventory install!

	Before proceeding, please make sure you have the following."

	prompt "
	Access requirements:

	- Docker Hub account https://hub.docker.com
	- Access to our Vinlab org at Docker Hub
		- For example, you have received and accepted an invitation to *enduser* team at Vinlab org" "
	I do have these (y/N) "

	prompt "
	Software requirements:

	- OS X 10.x or higher
	- Docker
	- Docker-compose (installed as part of Docker on OS X)
	- Docker engine is running in Swarm mode
		- Run 'docker swarm init' (or 'docker swarm join') command at least once
		- This is required for encryption

	(If you are not sure about any of these, please consult Code Inventory documentation)" "
	Yes, I do have all these (y/N) "

	prompt "
	Login requirements:

	- You are logged in to Docker Hub
		- Run 'docker login' command at least once
		- This is required for pulling Code Inventory's docker images" "
	I am logged in, let's go (y/N) "

	prompt "
	"
}

require_docker() {
	if ! command_exists docker; then
      echo 'CHECKING IF DOCKER COMMAND IS AVAILABLE>' >&2
	  echo 'Docker command not found, you need to install Docker first. Exiting.' >&2
	  exit 1
	fi
	if ! command_exists docker-compose; then
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

docker_secret_exists(){
	if docker secret ls | grep -w "$1" &> /dev/null; then
		true
	else
		false
	fi
}

create_master_password(){
	# Check if master password already exists, prompt to keep/overwrite
	already_exists=false
	want_to_overwrite=false
	if docker_secret_exists 'code-inventory-master-password'; then
		already_exists=true
		if ! prompt_Yn "Master password already exists, do you want to keep it (recommended)? (Y/n) "; then
			if ! prompt_Yn "
			Overwriting an already existing master password is NOT recommended.
			The master password is used in encrypting sensitive data in Code Inventory's database.
			If it is changed, existing encrypted data will not be able to be decrypted anymore.

			Only overwrite the master password in certain circumstances, for instance:
			- When performing a clean install / not restoring from backup
			- When restoring from a backup which has a different master password" "
			OK, keep my existing master password (Y/n) "; then
				if prompt_yN "
			YOUR MASTER PASSWORD WILL NOW BE REPLACED, AND YOU WILL LOSE THE ABILITY TO
			USE ENCRYPTED DATA CURRENTLY IN CODE INVENTORY DATABASE, AS WELL AS IN ANY
			BACKUPS THAT WERE MADE USING THE PREVIOUS MASTER PASSWORD" "
			I understand implications, go ahead (y/N) "; then
					want_to_overwrite=true
				fi
			fi
		fi
		if ! $want_to_overwrite; then
			echo "Keeping existinig master password"
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

create_docker_secrets(){
	if ! docker_secret_exists 'code-inventory-db-backend-password'; then
		echo 'U21hcnQtYmFuYW5hcy1zaWxseS1udXRzLTU3Cg==' | base64 -D | docker secret create code-inventory-db-backend-password -
	fi
	if ! docker_secret_exists 'code-inventory-db-postgres-password'; then
		echo 'Rm9nLWNpdHktbWFtYmEtMjcK' | base64 -D | docker secret create code-inventory-db-postgres-password -
	fi
	if ! docker_secret_exists 'code-inventory-db-grafana-password'; then
		echo 'Q2Fzc2Vyb2xlLTc0Nwo=' | base64 -D | docker secret create code-inventory-db-grafana-password -
	fi
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
create_docker_secrets
echo 'CREATING DOCKER SECRETS>DONE'

exit_sequence
cd ${FROM_DIR}
