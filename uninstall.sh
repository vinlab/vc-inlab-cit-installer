#!/bin/sh
#
# Uninstall Code Inventory
#
# Removes:
# - Code Inventory Assembly files
# - Code Inventory docker secrets, except for the master password
# - Code Inventory job files
#
# Will not remove:
# - Master Password
# - Postgres data
# - Grafana data
#
# Author: Andrey Potekhin

home_dir=~/.veracode/code-inventory
assembly_dir=$home_dir/bin
jobs_dir=$home_dir/jobs

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
	Uninstall Code Inventory

	Code Inventory will be removed from your system." "
	Do you want to proceed? (y/N) "

	prompt "
	The uninstallation will not remove your data (e.g. the database).
	To completely remove your data:

	- Manually delete $home_dir dir" "
	Proceed with uninsall? (y/N) "

	echo
}

docker_exists() {
	if ! command_exists docker; then
    echo 'CHECKING IF DOCKER COMMAND IS AVAILABLE>' >&2
	  echo 'Docker command not found.' >&2
	  false
		return
	fi
	true
}

docker_swarm_exists() {
	if [ -z "`docker info | grep -F 'Swarm:'`" ]; then
    echo 'CHECKING IF DOCKER SWARM IS AVAILABLE>' >&2
	  echo 'Docker swarm not found.' >&2
		false
		return
	fi
	if [ -z "`docker info | grep -F 'Swarm: active'`" ]; then
    echo 'CHECKING IF DOCKER SWARM IS ACTIVE>' >&2
	  echo 'Docker swarm not active.' >&2
		false
		return
	fi
	if ! docker node ls &> /dev/null; then
    echo 'CHECKING WHETHER THIS NODE IS PART OF DOCKER SWARM>' >&2
    docker node ls  >&2
	  echo 'This node is not part of docker swarm.' >&2
		false
		return
	fi
	true
}

code_inventory_is_running(){
	if docker container ls | grep -wq 'docker_code_inventory_backend-app_1'; then
		true
	elif docker container ls | grep -wq 'docker_code_inventory_backend-postgresql_1'; then
		true
	elif docker container ls | grep -wq 'docker_code_inventory_backend-grafana_1'; then
		true
	else
		false
	fi
}

require_code_inventory_not_running(){
	if code_inventory_is_running; then
		echo 'CHECKING IF CODE INVENTORY IS RUNNING>' >&2
	  echo 'Code Inventory is currently running. Please stop Code Inventory and re-try. ' >&2
	  exit 1
	fi
}

code_inventory_is_installed(){
	if [ -d "$home_dir" ]; then
		true
	else
		false
	fi
}

require_code_inventory_installed(){
	if ! code_inventory_is_installed; then
	  echo 'Code Inventory installation not found. Exiting.' >&2
	  exit 1
	fi
}

docker_present=false

startup_sequence(){
	if ! docker_exists; then
		echo 'WARNING: Docker command not found'
	fi
	if ! docker_swarm_exists; then
		echo 'WARNING: Docker swarm not found'
	fi
	if docker_exists && docker_swarm_exists; then
		docker_present=true
	fi
	require_code_inventory_not_running
}

docker_secret_exists(){
	if docker secret ls | grep -wq "$1"; then
		true
	else
		false
	fi
}

remove_docker_secrets(){
	if docker_secret_exists 'code-inventory-db-backend-password'; then
		docker secret rm code-inventory-db-backend-password
	fi
	if docker_secret_exists 'code-inventory-db-postgres-password'; then
		docker secret rm code-inventory-db-postgres-password
	fi
	if docker_secret_exists 'code-inventory-db-grafana-password'; then
		docker secret rm code-inventory-db-grafana-password
	fi
}

verify_docker_secrets(){
	result=true
	if docker_secret_exists 'code-inventory-db-backend-password'; then
		echo 'VERIFYING DOCKER SECRETS>' >&2
		echo 'Failed to remove docker secret: code-inventory-db-backend-password'
		result=false
	fi
	if docker_secret_exists 'code-inventory-db-postgres-password'; then
		echo 'VERIFYING DOCKER SECRETS>' >&2
		echo 'Failed to remove docker secret: code-inventory-db-postgres-password'
		result=false
	fi
	if docker_secret_exists 'code-inventory-db-grafana-password'; then
		echo 'VERIFYING DOCKER SECRETS>' >&2
		echo 'Failed to remove docker secret: code-inventory-db-grafana-password'
		result=false
	fi
	if ! $result; then
		echo 'DOCKER SECRETS VERIFICATION FAILED'
	fi
}

delete_jobs_dir(){
	if [ -d "$jobs_dir" ]; then
		echo "Deleting $jobs_dir"
		rm -r "$jobs_dir"
	fi
}

delete_assembly_dir(){
	if [ -d "$assembly_dir" ]; then
		echo "Deleting $assembly_dir"
		rm -r "$assembly_dir"
	fi
}

verify_uninstalled_files(){
	result=true
	if [ -d "$jobs_dir" ]; then
		echo 'VERIFYING UNINSTALLED FILES>' >&2
		echo "Directory still exists: $jobs_dir"
		result=false
	fi
	if [ -d "$assembly_dir" ]; then
		echo 'VERIFYING UNINSTALLED FILES>' >&2
		echo "Directory still exists: $assembly_dir"
		result=false
	fi
	if ! $result; then
		echo 'UNINSTALLED FILES VERIFICATION FAILED'
	fi
}

exit_sequence(){
	verify_docker_secrets
	verify_uninstalled_files
}

FROM_DIR=`pwd`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${DIR}

startup_prompt
echo 'CHECKING UNINSTALL PREREQUISITES>'
startup_sequence
echo 'CHECKING UNINSTALL PREREQUISITES>DONE'

echo 'CHECKING IF CODE INVENTORY IS INSTALLED>'
require_code_inventory_installed
echo 'CHECKING IF CODE INVENTORY IS INSTALLED>DONE'

echo 'DELETING CODE INVENTORY JOBS DIR>'
delete_jobs_dir
echo 'DELETING CODE INVENTORY JOBS DIR>DONE'

echo 'DELETING CODE INVENTORY ASSEMBLY SCRIPTS>'
delete_assembly_dir
echo 'DELETING CODE INVENTORY ASSEMBLY SCRIPTS>DONE'

if $docker_present; then
	echo 'REMOVING DOCKER SECRETS>'
	remove_docker_secrets
	echo 'REMOVING DOCKER SECRETS>DONE'
fi

exit_sequence
cd ${FROM_DIR}
