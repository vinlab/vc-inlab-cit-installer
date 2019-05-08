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

# Constants that vary between releases
# (Constants are kept in same file to allow script runs over curl)
BACKEND_DOCKER_IMAGE=vinlab/code-inventory-backend:latest
POSTGRES_DOCKER_IMAGE=vinlab/vc-inlab-cit-postgres:1.0.0
GRAFANA_DOCKER_IMAGE=vinlab/vc-inlab-cit-grafana:1.0.1
FRONTEND_DOCKER_IMAGE=vinlab/vc-inlab-cit-frontend:latest
ASSEMBLY_DOCKER_IMAGE=vinlab/vc-inlab-cit-assembly:latest

APP='CODE INVENTORY'
App='Code Inventory'

home_dir=~/.veracode/code-inventory
assembly_dir=${home_dir}/bin
jobs_dir=${home_dir}/jobs
grafana_dir=${home_dir}/grafana


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
  Welcome to ${App} install!

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

	(If you are not sure about any of these, please consult ${App} documentation)" "
  Yes, I do have all these (y/N) "

  prompt "
	Login requirements:

	- You are logged in to Docker Hub
		- Run 'docker login' command at least once
		- This is required for pulling ${App}'s docker images" "
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
}

docker_container_exists(){
  # We do not use -w flag, to allow for checking by container infix
  # Example: docker_container_exists 'code_inventory_backend-app'
  # will return true for both 'docker_code_inventory_backend-app_1'
  # as well as for 'code-inventory_code_inventory_backend-app.1.loe6skwa6i60jnqi4ja75723h'
  # (last name is specific to docker stack runs)
	docker container ls | grep --silent "$1"
}

require_container_not_running() {
  if docker_container_exists "$1"; then
      echo 'CHECKING FOR RUNNING APPLICATION CONTAINERS>' >&2
	  echo "One of ${App} containers is currently running: $1. Please stop ${App} before proceeding." >&2
	  exit 1
	fi
}

require_app_not_running() {
  if docker_container_exists 'code_inventory_backend-app'; then
      echo 'CHECKING IF APPLICATION IS CURRENTLY RUNNING>' >&2
	  echo "${App} is currently running, please stop it before proceeding." >&2
	  exit 1
	fi
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

docker_secret_exists(){
  if docker secret ls | grep -w "$1" &> /dev/null; then
    true
  else
    false
  fi
}

create_master_password(){
  already_exists=false
  want_to_overwrite=false
  if docker_secret_exists 'code-inventory-master-password'; then
    already_exists=true
    if ! prompt_Yn "Master password already exists, do you want to keep it (recommended)? (Y/n) "; then
      if ! prompt_Yn "
        Overwriting an already existing master password is NOT recommended.
        The master password is used in encrypting sensitive data in ${App}'s database.
        If it is changed, existing encrypted data will not be able to be decrypted anymore.

        Only overwrite the master password in certain circumstances, for instance:
        - When performing a clean install / not restoring from backup
        - When restoring from a backup which has a different master password" "
        OK, keep my existing master password (Y/n) "; then
        if prompt_yN "
        YOUR MASTER PASSWORD WILL NOW BE REPLACED, AND YOU WILL LOSE THE ABILITY TO
        USE ENCRYPTED DATA CURRENTLY IN ${APP} DATABASE, AS WELL AS IN ANY
        BACKUPS THAT WERE MADE USING THE PREVIOUS MASTER PASSWORD" "
        I understand implications, go ahead (y/N) "; then
          want_to_overwrite=true
        fi
      fi
    fi
    if ! ${want_to_overwrite}; then
      echo "Keeping existinig master password"
    fi
  fi
  if ! ${already_exists} || ${want_to_overwrite}; then
    # Prompt for master password
    read -p 'Create master password, for encryption purposes: ' -r -s
    master_password=$REPLY
    echo
    read -p 'Confirm master password: ' -r -s
    master_password_confirmation=$REPLY
    echo
    if [ ${master_password} -ne ${master_password_confirmation} ]; then
      echo "Passwords do not match, please retry"
      #TODO: implement retrying password entry
      verify_master_password
    fi
    # Remove master password docker secret, if any
    if ${already_exists}; then
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
    if ! echo ${master_password} | docker secret create code-inventory-master-password -; then
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

verify_docker_secrets(){
  result=true
  if ! docker_secret_exists 'code-inventory-db-backend-password'; then
    echo 'VERIFYING DOCKER SECRETS>' >&2
    echo 'Failed to create docker secret: code-inventory-db-backend-password'
    result=false
  fi
  if ! docker_secret_exists 'code-inventory-db-postgres-password'; then
    echo 'VERIFYING DOCKER SECRETS>' >&2
    echo 'Failed to create docker secret: code-inventory-db-postgres-password'
    result=false
  fi
  if ! docker_secret_exists 'code-inventory-db-grafana-password'; then
    echo 'VERIFYING DOCKER SECRETS>' >&2
    echo 'Failed to create docker secret: code-inventory-db-grafana-password'
    result=false
  fi
  if ! ${result}; then
    exit 1
  fi
}

pull_docker_image() {
  if ! docker pull "$1"; then
    echo "Failed to pull docker image: $1." >&2
    echo "Are you logged in to Docker Hub? Please run 'docker login' command!" >&2
    false
  else
    true
  fi
}

pull_docker_images(){
  if ! pull_docker_image ${BACKEND_DOCKER_IMAGE} \
  || ! pull_docker_image ${POSTGRES_DOCKER_IMAGE} \
  || ! pull_docker_image ${GRAFANA_DOCKER_IMAGE} \
  || ! pull_docker_image ${ASSEMBLY_DOCKER_IMAGE} \
  || ! pull_docker_image ${FRONTEND_DOCKER_IMAGE}
  then
    exit 1
  fi
}

docker_image_exists() {
  # We do not use -w flag, to allow for checking by container infix
  # Example: docker_image_exists 'code_inventory_backend'
  # will return true for both 'vinlab/code_inventory_backend:latest'
  # as well as for 'vinlab/code_inventory_backend:1.0.1'
  docker image ls  --format '{{.Repository}}:{{.Tag}}' | grep --silent "$1"
}

verify_docker_image() {
  if ! docker_image_exists "$1"; then
    echo 'VERIFYING DOCKER IMAGES>' >&2
    echo "Failed to verify docker image - docker image is missing: $1." >&2
    false
  else
    true
  fi
}

verify_docker_images(){
  if ! verify_docker_image ${BACKEND_DOCKER_IMAGE} \
  || ! verify_docker_image ${POSTGRES_DOCKER_IMAGE} \
  || ! verify_docker_image ${GRAFANA_DOCKER_IMAGE} \
  || ! verify_docker_image ${ASSEMBLY_DOCKER_IMAGE} \
  || ! verify_docker_image ${FRONTEND_DOCKER_IMAGE}
  then
    exit 1
  fi
}

create_dir_if_missing() {
	if ! [ -d "$2" ]; then
		echo "Creating $1 dir: $2"
		mkdir -p "$2"
	fi
}

install_assembly_scripts(){
  create_dir_if_missing "application home" "${home_dir}"
  container=`docker create --rm ${ASSEMBLY_DOCKER_IMAGE}`
  if [ -z "${container}" ]; then
    echo 'CREATING ASSEMBLY CONTAINER>'
    echo "Failed to create container for image ${ASSEMBLY_DOCKER_IMAGE}"
    exit 1
  fi
  copy_to_dir=${assembly_dir}
	if [ -d "${copy_to_dir}" ]; then
	  # ${assembly_dir} already exists. We need to supply one-vevel-above dir
	  # to the docker cp command, otherwise it will create an extra bin/ dir,
	  # resulting in ${home_dir}/bin/bin
    echo 'BINARIES DIR ALREADY EXISTS, OVERWRITING>'
    copy_to_dir=${home_dir}
	fi
  if ! docker cp "${container}:/var/bin" "${copy_to_dir}"; then
    echo 'COPYING ASSEMBLY BINARIES>'
    echo "Failed to copy assembly binaries to ${assembly_dir}"
    exit 1
  fi
  if ! docker rm "${container}" --force; then
    echo 'REMOVING ASSEMBLY CONTAINER>'
    echo "WARNING: Failed to remove assembly container"
  fi
	if ! [ -d "${assembly_dir}" ]; then
    echo 'VERIFYING ASSEMBLY BINARIES DIR>'
    echo "Assembly binaries dir not found: ${assembly_dir}"
    exit 1
  fi
}

check_if_app_installed(){
  if docker_image_exists ${BACKEND_DOCKER_IMAGE} \
  || docker_image_exists ${FRONTEND_DOCKER_IMAGE}; then
    echo 'CHECKING IF APPLICATION ALREADY INSTALLED>' >&2
    if ! prompt_Yn "
    ${App} is already installed." "
    Proceed with reinstall? (Your existing data will not be affected.) (Y/n) "; then
      exit 0
    fi
  fi
}

verify_dir(){
	if ! [ -d "$2" ]; then
    echo 'VERIFYING INSTALLED FILES>' >&2
    echo "Missing $1 dir: $2" >&2
    false
	else
	  true
	fi
}

verify_installed_files() {
  if ! verify_dir "application home" ${home_dir} \
  || ! verify_dir "application binaries" ${assembly_dir}; then
    echo "${APP} INSTALLATION HAS FAILED"
    exit 1
  fi
}

#
# INSTALL CODE INVENTORY
#
from_dir=`pwd`
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${dir} || exit 1

startup_prompt

echo 'CHECKING SETUP PREREQUISITES>'
require_docker
require_docker_swarm
require_docker_login
require_app_not_running
require_container_not_running 'code_inventory_backend-postgres'
require_container_not_running 'code_inventory_backend-grafana'
require_container_not_running 'code_inventory_frontend-app'
echo 'CHECKING SETUP PREREQUISITES>DONE'

echo "CHECKING IF ${APP} IS ALREADY INSTALLED>"
check_if_app_installed
echo "CHECKING IF ${APP} IS ALREADY INSTALLED>DONE"

echo "PULLING ${APP} DOCKER IMAGES>"
pull_docker_images
verify_docker_images
echo "PULLING ${APP} DOCKER IMAGES>DONE"

echo "INSTALLING ${APP} ASSEMBLY SCRIPTS>"
install_assembly_scripts
echo "INSTALLING ${APP} ASSEMBLY SCRIPTS>DONE"

echo 'MASTER PASSWORD>'
create_master_password
echo 'MASTER PASSWORD>DONE'

echo 'CREATING DOCKER SECRETS>'
create_docker_secrets
echo 'CREATING DOCKER SECRETS>DONE'

verify_master_password
verify_docker_secrets
verify_installed_files

echo "${APP} INSTALLED>"

echo "
  ${App} is now installed.

  ${App}'s home directory: ${home_dir}

  1. To start and stop ${App} at any time, run the following scripts located in home directory:
    ./start.sh - Start ${App}, show logs of normal levels (INFO, WARN, ERROR)
    ./stop.sh - Stop ${App}
    ./start+logs.sh - Start and show logs up to DEBUG level
    ./start+trace.sh - Start and show logs up to TRACE level
    ./start-silent.sh - Start without showing the logs

  2. ${App} always runs in as docker stack (similar to daemon) mode. That means, that you can
  press ^C at any point to stop the logs from coming to your screen - ${App} will continue to run.

  3. To stop ${App}, run ./stop.sh from application home directory."

if prompt_Yn "
  Would you like to run ${App} now? (Y/n) "; then
  if prompt_Yn "
    Recap: the application will start as daemon. Please use ^C at any point to stop the logs from coming to screen.
    Use the ./stop.sh script from app home directory (${home_dir}) to completely stop the application.

    I got it, let's run (Y/n)
    "; then
    ${assembly_dir}/start.sh
  fi
fi

cd ${from_dir} || exit 1
