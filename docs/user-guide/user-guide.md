# User Guide

# Prerequisites

Git (until we deploy installer through curl)

# Install

## Prerequisites

Verify these before installing:

1. Docker is present in your system `docker --version`
2. Docker id started, docker daemon is running `docker container ls`
3. Docker is in Swarm mode `docker swarm init`

## Clone Installer

> In the future, Clone and Run Installer steps will be replaced with a single curl command similar to `curl -fsS [https://codeinventory.com/latest/install](https://codeinventory.com/latest/install) | bash`

Clone Code Inventory installer from GitHub to local system

    git clone https://github.com/vinlab/vc-inlab-cit-installer.git

Cd to Code Inventory Installer folder:

    cd vc-inlab-cit-installer

## Run Installer

    ./install.sh

Code Inventory will be installed into `~/.veracode/code-inventory` 

Start and stop scripts are located in  `~/.veracode/code-inventory/bin` 

Here is a little video (best enjoyed full-screen):

[CIT_Install-2a43d70c-760f-460b-80fc-3695cae991b1.mp4](CIT_Install-2a43d70c-760f-460b-80fc-3695cae991b1.mp4)

# Access Code Inventory

Code Inventory is available at 

[http://127.0.0.1:10100](http://127.0.0.1:10100/#/)

## Initial Setup

Have your GitHub personal access token handy. You will be guided to setting up an SCM. 

Perform initial SCM setup and start synching:

[CIT_Setup-d5d6d163-3630-44e9-bd07-fccc1e939f8c.mp4](CIT_Setup-d5d6d163-3630-44e9-bd07-fccc1e939f8c.mp4)

After code synching is done (which may take some time), analysis results are available in Grafana:

[CIT_Grafana-8bec9bb3-a7ee-4728-a4b6-b2a11d31fc8f.mp4](CIT_Grafana-8bec9bb3-a7ee-4728-a4b6-b2a11d31fc8f.mp4)

## Setup your Apps

In case you noticed that some panels in Grafana are empty, this is because we lack (so far) the apps. For Code Inventory, an 'app' is any subset of your source code repos. In other words, you bunch your repos into 'apps', and your apps become available for analysis:

[CIT_Setup_Apps-061de0b9-c686-41a2-9a74-a79f1f70492e.mp4](CIT_Setup_Apps-061de0b9-c686-41a2-9a74-a79f1f70492e.mp4)

# Access API documentation

If you are developer, Backend API Swagger documentation is available at 

[http://127.0.0.1:10101/#/admin/docs](http://localhost:10101/#/admin/docs)

Username: **admin/admin**

![](ScreenShot2018-12-04at12-198de820-72c9-42cf-8345-77ad89689f24.18.15AM.png)

## also, Backend API Specification is available in PDF format:

[cit-backend-api-spec.pdf](cit-backend-api-spec-7a35402e-2017-455b-b6c2-ad5b2de02145.pdf)

# Access API endpoints

The API endpoints and usage examples are available at:

[`http://127.0.0.1:10101/#/admin/docs`](http://localhost:10101/#/admin/docs)

## Authenticate

Before using Backend API from your client app/curl/Postman, you need to obtain a JWT token by authenticating into the API. Send a POST request to [`http://127.0.0.1:10101/api/authenticate`](http://localhost:10101/api/authenticate) endpoint and the body as shown:

    POST http://127.0.0.1:10101/api/authenticate
    
    Body:
    {
    	"username":"admin",
    	"password":"admin"
    }

## Examples

Postman

![](ScreenShot2018-12-04at12-d91e7984-014e-4e40-9ce8-64342d104561.20.35AM.png)

Curl command

    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{   "password": "admin",   "rememberMe": true,    "username": "admin"  }' 'http://127.0.0.1:10101/api/authenticate'

## Response

The JWT token will be returned in response body

    {
      "id_token" : "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImF1dGgiOiJST0xFX0FETUlOLFJPTEVfVVNFUiIsImV4cCI6MTU0NjUwMzU5MH0.j_JfHze_gw-ZcpG2_9fCX3s8UR0o-MrS5feakzfuMsrJfcRn2xH9nCeczQCnS7I1fFM2_FUBUOJ_JVyUn9GAHQ"
    }

Now you can add this token to your requests to Backend API:

    Header: Authorization
    Value: Bearer [token]

# Shut Down/Stop Code Inventory Application

    cd ~/.veracode/code-inventory/bin
    ./stop.sh

# Troubleshooting

See [troubleshooting.md](../troubleshooting/troubleshooting.md)


# Grafana

Our analytics and dashboarding tool Grafana automatically starts as part of CIT Backend, when you start the app using `docker stack` command. If, however, you start CIT Backend using Maven command (`./mvnw`), or if you don't have CIT infras running, Grafana can be started manually:

    cd ~/.veracode/code-inventory/bin
    ./start-infra.sh

Verify Grafana is running:

    docker container ls
    Output:
    CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                     NAMES
    7c40c8e1b799        docker_code_inventory_backend-grafana   "/run.sh"                13 hours ago        Up 13 hours         0.0.0.0:10110->3000/tcp   docker_code_inventory_backend-grafana_1

Also, it is possible to start Grafana and view its logs:

    cd ~/.veracode/code-inventory/bin
    ./start-infra.sh
    ./logs.grafana.sh

## **Access Grafana**

open [http://127.0.0.1:10110](http://127.0.0.1:10110) 

Username/password: **admin/secret**

![](ScreenShot2019-02-05at11-5af1d299-d7d7-4e4b-b86c-bad6ef03fa36.32.35AM.png)

## Force restart Grafana

If accessing the above URL results in errors, one can try force restart Grafana. These steps also rebuild Grafana image. Note: these steps are performed from CIT Backend project source dir. So the Backend must be cloned into your local system to perform these steps.

    cd ~/.veracode/code-inventory/bin
    ./stop.sh
    ./start-infra.sh

It also makes sense to follow Grafana logs and collect/record any error messages.

## **Grafana Logs**

    cd ~/.veracode/code-inventory/bin
    ./logs.grafana.sh

## **Logging into Grafana Docker image**

    docker exec -it --user root "`docker container ls | grep 'code_inventory_backend-grafana' | awk '{print $NF}'`" /bin/bash

## Installing a plugin

> Plugins can't be persisted to local at the moment (issue [https://github.com/vinlab/vc-inlab-cit-backend/issues/119](https://github.com/vinlab/vc-inlab-cit-backend/issues/119)). Please share plugin's URL with dev team for provisioning from back end. You will have it then automatically included with the next CIT Backend build.

[The following steps are only relevant after the above issue has been resolved]

To install Grafana plugin

- Navigate to plugin page
Example: Pie Chart [https://grafana.com/plugins/grafana-piechart-panel](https://grafana.com/plugins/grafana-piechart-panel)
- Get grafana-cli command from plugin page.
Example: `grafana-cli plugins install grafana-piechart-panel`
- Log in to Grafana Docker image
    `docker run -ti --user root --entrypoint bash vinlab/vc-inlab-cit-grafana`
- Run grafana-cli command inside the Docker image:

        / # grafana-cli plugins install grafana-piechart-panel
    
        Output:
        ✔ Installed grafana-piechart-panel successfully 
         Restart grafana after installing plugins . <service grafana-server restart>

- Exit Docker image: `exit`
- Restart Grafana:

          docker stack down code-inventory && sleep 10 && docker container ls #stop infra
          docker stack up -c src/main/docker/app.yml code-inventory && sleep 6 && docker logs -f "`docker container ls | grep 'code_inventory_backend-app' | awk '{print $NF}'`"

- Open Grafana UI Plugins page and verify plugin is now part of in your Grafana instance:
open [http://127.0.0.1:10110/plugins](http://127.0.0.1:10110/plugins)
or
open [http://127.0.0.1:10110/](http://127.0.0.1:10110/) and see Installed Apps, Installed Panels sections
- You can start using the plugin in your dashboarding. If you like the results, communicate the grafana-cli command to dev team for provisioning with our custom Grafana, so it would be available for all app users.

## Stopping Grafana

    cd ~/.veracode/code-inventory/bin
    ./stop.sh

## Grafana locations

On host file system

Grafana: **~/.veracode/code-inventory/grafana**

Provisioning: **~/.veracode/code-inventory/grafana/provisioning**

Inside Grafana Docker image

The above locations are mapped from the following dirs:

**/var/lib/grafana**

**/etc/grafana/provisioning/**

## More info

# Logs

The application follows JHipster framework defaults to log to standard output (console). Docker infrastructure then exposes these logs through `docker logs` command as shown below.

## If ran with ./start.sh command

If `./start.sh` command was used to to start the app, the app logs are standard output e.g.  Terminal window:

    ----------------------------------------------------------
    	Code Inventory is now running. Access URLs:
    	Front-end, local: 	http://127.0.0.1:10100/
    	Front-end, external: 	http://10.0.19.8:10100/
    	API, local: 		http://127.0.0.1:10101/api
    	API, external: 		http://10.0.19.8:10101/api
    	Release version: 1.1.2
    	Profile(s): 	[prod, swagger]
    ----------------------------------------------------------

You can always Ctrl-C (won't stop the Code Inventory itself) to stop the logs from pouring to screen. Come back to viewing logs by using these scripts:

    cd ~/.veracode/code-inventory/bin
    ./logs.frontend.sh
    ./logs.backend.sh
    ./logs.postgres.sh
    ./logs.grafana.sh

## If ran with ./start-silent.sh command

If `./start-silent.sh` command was used to to start the app, the app logs are only available via following scripts:

    cd ~/.veracode/code-inventory/bin
    ./logs.frontend.sh
    ./logs.backend.sh
    ./logs.postgres.sh
    ./logs.grafana.sh

# File Locations

Q: Where does Code Inventory store its data?

A: 

**~/.veracode/code-inventory/**

Subdirs:

Algorithms: **~/.veracode/code-inventory/algorithms**

Code: **~/.veracode/code-inventory/code**

Jobs: **~/.veracode/code-inventory/jobs**

Data: **~/.veracode/code-inventory/data**

Database: **~/.veracode/code-inventory/data/postgresql**

Grafana: **~/.veracode/code-inventory/grafana**

Grafana Provisioning: **~/.veracode/code-inventory/grafana/provisioning**

Note:

For developers, if you started the app using `./mvnw` command rather than docker command, then the Code and Jobs dirs will be located under **[project]/target**:

Code: **[project]/.code**

Jobs: **[project]/.jobs**

# Backup

## 1. To backup/restore database (only)

Run Code Inventory (`./start.sh`) or its infrastructure pieces (Postgres and Grafana) (`./start-infra.sh`)

    cd ~/.veracode/code-inventory/bin
    ./start-infra.sh

Verify our db container (docker_code_inventory_backend-postgresql_1) is started

    docker container ls
    CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                    NAMES
    5120bd49c821        vinlab/vc-inlab-cit-postgres:1.0.0     "docker-entrypoint.s…"    2 hours ago         Up 2 hours          10111/tcp            code-inventory_code_inventory_backend-postgresql.1.8ec5w9lkdz56esbtsom7cbtno

## Backup Database

    docker exec -t -i -e PGPASSWORD=Fog-city-mamba-27 \
     "`docker container ls | grep 'code_inventory_backend-postgres' | awk '{print $NF}'`" \
     pg_dumpall -c -U postgres > dump.sql

## Restore Database

Note: 

- Restoring a backup overrides the data currently in the database
- For best results, close all possible connection to the database before restoring, e.g. shut down the apps using the database, GUI clients etc.

        cat dump.sql | docker exec -i -e PGPASSWORD=Fog-city-mamba-27 \
        "`docker container ls | grep 'code_inventory_backend-postgres' | awk '{print $NF}'`" \
        psql -U postgres #restore database

## 2. To backup/restore the whole Code Inventory app (including the database and all settings)

Backup/restore app directory:

**~/.veracode/code-inventory/**

# Database

## Starting the database server

Starting manually: if you are using `./mvnw` command to start the app, here is how you start the database before you run the app:

    cd ~/.veracode/code-inventory/bin
    ./start-infra.sh

If Docker command was used to start the app (`docker stack up -c src/main/docker/app.yml code-inventory`), the database server is already running and available.

## Verify db server is running

    docker container ls
    Verify that docker_code_inventory_backend-postgresql_1 is present:
    5120bd49c821        vinlab/vc-inlab-cit-postgres:1.0.0     "docker-entrypoint.s…"    2 hours ago         Up 2 hours          10111/tcp            code-inventory_code_inventory_backend-postgresql.1.8ec5w9lkdz56esbtsom7cbtno

## Connecting to database

Connect:

Host: [localhost](http://localhost)

Port: 10111

Database: code_inventory_backend

User: postgres

Pwd: Fog-city-mamba-27

Note: the database **code_inventory_backend** is auto-created on app's first run. That means, you have to run CIT Backend at least once before you can connect to the database!

# Uninstall

If you need to completely remove Code Inventory from your system:

    cd vc-inlab-cit-installer
    ./uninstall.sh

Here is a little video:

[CIT_ninstall-1fa22f01-fb60-4e82-baca-356b2a8c0f2a.mp4](CIT_ninstall-1fa22f01-fb60-4e82-baca-356b2a8c0f2a.mp4)