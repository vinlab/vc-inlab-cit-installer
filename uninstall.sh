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

# Constans that vary between releases
# (Constants are kept in same file to allow script runs over curl)
BACKEND_DOCKER_IMAGE=vinlab/code-inventory-backend:latest
POSTGRES_DOCKER_IMAGE=vinlab/vc-inlab-cit-postgres:1.0.0
GRAFANA_DOCKER_IMAGE=vinlab/vc-inlab-cit-grafana:1.0.1
FRONTEND_DOCKER_IMAGE=vinlab/code-inventory-frontend:latest

home_dir=~/.veracode/code-inventory
assembly_dir=${home_dir}/bin
jobs_dir=${home_dir}/jobs
grafana_dir=${home_dir}/grafana
data_dir=${home_dir}/data

docker_present=false
delete_user_data=false

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

docker_container_exists(){
  # We do not use -w flag, to allow for checking by container infix
  # Example: docker_container_exists 'code_inventory_backend-'
  # will return true for both 'docker_code_inventory_backend-app_1'
  # as well as for 'code-inventory_code_inventory_backend-app.1.loe6skwa6i60jnqi4ja75723h'
  # (last name is specific to docker stack runs)
	docker container ls | grep --silent "$1"
}

require_app_not_running() {
  if docker_container_exists 'code_inventory_backend-app'; then
      echo 'CHECKING IF APPLICATION IS CURRENTLY RUNNING>' >&2
	  echo 'Code Inventory is currently running, please stop it before proceeding.' >&2
	  exit 1
	fi
}

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
	require_app_not_running
}

docker_image_exists() {
  # We do not use -w flag, to allow for checking by container infix
  # Example: docker_image_exists 'code_inventory_backend'
  # will return true for both 'vinlab/code_inventory_backend:latest'
  # as well as for 'vinlab/code_inventory_backend:1.0.1'
  docker image ls  --format '{{.Repository}}:{{.Tag}}' | grep --silent "$1"
}

delete_docker_image() {
  if ! docker_image_exists "$1"; then
    echo "Not found: $1." >&2
    true
  elif ! docker rmi --force "$1"; then
    echo "Failed to delete docker image: $1." >&2
    false
  else
    true
  fi
}

delete_docker_images(){
  if ! delete_docker_image ${BACKEND_DOCKER_IMAGE} \
  || ! delete_docker_image ${POSTGRES_DOCKER_IMAGE} \
  || ! delete_docker_image ${GRAFANA_DOCKER_IMAGE}
  #|| ! delete_docker_image ${FRONTEND_DOCKER_IMAGE}
  then
    exit 1
  fi
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
  if ${delete_user_data}; then
    if docker_secret_exists 'code-inventory-db-backend-password'; then
      echo 'VERIFYING DOCKER SECRETS>' >&2
      echo 'Docker secret still present: code-inventory-db-backend-password'
      result=false
    fi
    if docker_secret_exists 'code-inventory-db-postgres-password'; then
      echo 'VERIFYING DOCKER SECRETS>' >&2
      echo 'Docker secret still present: code-inventory-db-postgres-password'
      result=false
    fi
    if docker_secret_exists 'code-inventory-db-grafana-password'; then
      echo 'VERIFYING DOCKER SECRETS>' >&2
      echo 'Docker secret still present: code-inventory-db-grafana-password'
      result=false
    fi
    if ! ${result}; then
      echo 'DOCKER SECRETS VERIFICATION FAILED'
      exit 1
    fi
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

delete_data_dir(){
	if [ -d "$data_dir" ]; then
		echo "Deleting $data_dir"
		rm -r "$data_dir"
	fi
}

delete_grafana_dir(){
	if [ -d "$grafana_dir" ]; then
		echo "Deleting $grafana_dir"
		rm -r "$grafana_dir"
	fi
}

verify_uninstalled_files(){
	result=true
  if ${delete_user_data}; then
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
  	if [ -d "$data_dir" ]; then
  		echo 'VERIFYING UNINSTALLED FILES>' >&2
  		echo "Directory still exists: $data_dir"
  		result=false
  	fi
  	if [ -d "$grafana_dir" ]; then
  		echo 'VERIFYING UNINSTALLED FILES>' >&2
  		echo "Directory still exists: $grafana_dir"
  		result=false
  	fi
  	if ! ${result}; then
  		echo 'UNINSTALLED FILES VERIFICATION FAILED'
  	fi
  fi
}

prompt_to_delete_user_data(){
  if prompt_yN "
        Delete user data? THIS WILL DELETE YOUR USER DATABASE
        AS WELL AS ALL CODE DOWNLOADED FOR ANALYSIS." "
        I understand implications, go ahead delete my data (y/N) "; then
    delete_user_data=true
  else
    delete_user_data=false
  fi
}

exit_sequence(){
	verify_docker_secrets
	verify_uninstalled_files
}

from_dir=`pwd`
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${dir} || exit 1


#prompt_to_delete_user_data
#exit 0

startup_prompt
echo 'CHECKING UNINSTALL PREREQUISITES>'
startup_sequence
echo 'CHECKING UNINSTALL PREREQUISITES>DONE'

echo 'CHECKING IF CODE INVENTORY IS INSTALLED>'
require_code_inventory_installed
echo 'CHECKING IF CODE INVENTORY IS INSTALLED>DONE'

echo 'DELETING CODE INVENTORY ASSEMBLY SCRIPTS>'
delete_assembly_dir
echo 'DELETING CODE INVENTORY ASSEMBLY SCRIPTS>DONE'

echo 'DELETING CODE INVENTORY DOCKER IMAGES>'
delete_docker_images
echo 'DELETING CODE INVENTORY DOCKER IMAGES>DONE'

prompt_to_delete_user_data

if ${delete_user_data}; then
  echo 'DELETING CODE INVENTORY JOBS DIR>'
  delete_jobs_dir
  echo 'DELETING CODE INVENTORY JOBS DIR>DONE'

  echo 'DELETING CODE INVENTORY GRAFANA DIR>'
#  delete_grafana_dir
  echo 'DELETING CODE INVENTORY GRAFANA DIR>DONE'

  echo 'DELETING CODE INVENTORY CODE DIR>'
#  delete_code_dir
  echo 'DELETING CODE INVENTORY CODE DIR>DONE'

  if ${docker_present}; then
  	echo 'REMOVING DOCKER SECRETS>'
#  	remove_docker_secrets
  	echo 'REMOVING DOCKER SECRETS>DONE'
  fi

  echo 'DELETING CODE INVENTORY DATABASE>'
#  delete_data_dir
  echo 'DELETING CODE INVENTORY DATABASE>DONE'

fi

exit_sequence
echo 'CODE INVENTORY IS UNINSTALLED>'

cd ${from_dir} || exit 1
