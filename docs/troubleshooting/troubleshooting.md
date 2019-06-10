# Troubleshooting

# Problems during Docker build

## Problem: 'events.js:167' 'throw er; // Unhandled 'error' event' message during  **app Docker build**

Command: `./mvnw package -Pprod jib:dockerBuild`

When: Maven build, Protractor/Selenium run

    [INFO] --- frontend-maven-plugin:1.6:npm (npm install) @ vc-inlab-cit-backend ---
    [INFO] Running 'npm install' in /Code/vc-inlab-cit/vc-inlab-cit-backend
    [INFO] 
    [INFO] > code-inventory-backend@0.0.0 postinstall /Code/vc-inlab-cit/vc-inlab-cit-backend
    [INFO] > webdriver-manager update --gecko false
    [INFO] 
    [INFO] [15:32:08] I/config_source - curl -o/Code/vc-inlab-cit/vc-inlab-cit-backend/node_modules/protractor/node_modules/webdriver-manager/selenium/standalone-response.xml https://selenium-release.storage.googleapis.com/
    [INFO] [15:32:08] I/config_source - curl -o/Code/vc-inlab-cit/vc-inlab-cit-backend/node_modules/protractor/node_modules/webdriver-manager/selenium/chrome-response.xml https://chromedriver.storage.googleapis.com/

Error: 

    [ERROR] events.js:167
    [ERROR]       throw er; // Unhandled 'error' event
    [ERROR]       ^
    [ERROR] 
    [ERROR] Error: getaddrinfo ENOTFOUND selenium-release.storage.googleapis.com selenium-release.storage.googleapis.com:443
    [ERROR]     at GetAddrInfoReqWrap.onlookup [as oncomplete] (dns.js:57:26)
    [ERROR] Emitted 'error' event at:
    [ERROR]     at Request.onRequestError (/Code/vc-inlab-cit/vc-inlab-cit-backend/node_modules/request/request.js:881:8)
    [ERROR]     at ClientRequest.emit (events.js:187:15)
    [ERROR]     at TLSSocket.socketErrorListener (_http_client.js:391:9)
    [ERROR]     at TLSSocket.emit (events.js:182:13)
    [ERROR]     at emitErrorNT (internal/streams/destroy.js:82:8)
    [ERROR]     at emitErrorAndCloseNT (internal/streams/destroy.js:50:3)
    [ERROR]     at process._tickCallback (internal/process/next_tick.js:63:19)
    [ERROR] npm ERR! code ELIFECYCLE
    [ERROR] npm ERR! errno 1
    [ERROR] npm ERR! code-inventory-backend@0.0.0 postinstall: `webdriver-manager update --gecko false`
    [ERROR] npm ERR! Exit status 1
    [ERROR] npm ERR! 
    [ERROR] npm ERR! Failed at the code-inventory-backend@0.0.0 postinstall script.
    [ERROR] npm ERR! This is probably not a problem with npm. There is likely additional logging output above.
    [ERROR] 
    [ERROR] npm ERR! A complete log of this run can be found in:
    [ERROR] npm ERR!     /Users/andrey/.npm/_logs/2018-12-22T23_32_09_027Z-debug.log

Cause: No Internet connection. Protractor tests require Internet connection.

Resolution: hop on to wi-fi.

# Problems during startup

> It is useful to issue `docker logs` command during/before app startup, to see app output:

    # start app and follow its logs:
    docker stack up -c src/main/docker/app.yml code-inventory && sleep 6 \
     && docker logs -f "`docker container ls | grep 'code_inventory_backend-app' | awk '{print $NF}'`"
    
    # or, follow app logs if app already started
    docker logs -f "`docker container ls | grep 'code_inventory_backend-app' | awk '{print $NF}'`"

## **Problem: Blank page, no content**

Cause 1: You are accessing wrong URL. Check the url: [http://127.0.0.1:10101](http://localhost:10101/#/team)

Cause 2: Docker has not started. Check if Docker Desktop is running; check Docker Preferences/General for 'Start Docker Desktop when you log in'

Cause 2: The app have not fully started. Sometimes, it takes some time (more than a minute). 

Cause 3: There is a mix-up of Docker containers. Use this command to clean Docker of orphans and dangling inmages:

`docker system prune`

Cause 4: Tha app is having problems, such as misconfiguration or db failure. Unfortunately, the docker stack command does not show a lot of output. 

To see app output, use `docker log` command

    docker logs -f "`docker container ls | grep 'code_inventory_backend-app' | awk '{print $NF}'`"

-or-

Start Backend using  `./mvnw` command

Examine the output of `./mvnw` command for errors, especially big exception stack outputs.

Report findings to Dev/Ops team.

## **Problem: application fails to start, 'PSQLException: The connection attempt failed.'**

Command: `./mvnw`

Call stack:

2019-02-18 17:30:08.984 ERROR 1 --- [ restartedMain] com.zaxxer.hikari.pool.HikariPool : HikariPool-1 - Exception during pool initialization.
org.postgresql.util.PSQLException: The connection attempt failed.
at org.postgresql.core.v3.ConnectionFactoryImpl.openConnectionImpl(ConnectionFactoryImpl.java:292)
at org.postgresql.core.ConnectionFactory.openConnection(ConnectionFactory.java:49)
at org.postgresql.jdbc.PgConnection.<init>(PgConnection.java:195)
at org.postgresql.Driver.makeConnection(Driver.java:454)

Cause: Database has not started.

Fix: start Postgres database image as follows:

    docker stack up -c src/main/docker/infra.yml code-inventory && sleep 6 && docker container ls

## **Problem: 'Could not obtain connection' message during startup**

Command: `./mvnw`

Error: 2018-11-30 13:42:53.263 WARN 2463 --- [ restartedMain] o.h.e.j.e.i.JdbcEnvironmentInitiator : HHH000342: Could not obtain connection to query metadata : Connection to localhost:10111 refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.

Cause: Database has not started.

Fix: start Postgres database image as follows:

    docker stack up -c src/main/docker/infra.yml code-inventory && sleep 6 && docker container ls

## **Problem: 'Unauthorized: Full authentication is required' messages during app run.**

Where: messages in Terminal output:

Message: Warning: 2018-11-30 13:53:31.885 WARN 2501 --- [ XNIO-2 task-24] o.z.problem.spring.common.AdviceTrait : Unauthorized: Full authentication is required to access this resource

Solution: You need to sign in to application in order to proceed:

![](ScreenShot2018-11-30at1-95714ce6-44b6-41cd-b693-66d0326472e4.56.01PM.png)

## **Problem: 'An error has occured :-(' on app homepage**

Where: accessing application homepage [http://127.0.0.1:10101](http://localhost:8080/#/admin/docs)

![](ScreenShot2018-12-03at3-064fc728-fb79-4d58-8d9d-410249f91d11.13.08PM.png)

Cause 1: The application has not yet fully started

Fix: give more time for application to start

Refresh the page. Sometimes several refreshes are needed.

Cause 2: JWT token used by front-end has become obsolete

Fix: restart the application. 

## Problem: blank page os shown when accessing [http://localhost:8080](http://localhost:8080/)

Error: 'Safari can't connect to the Server', or similar

Cause: You are using a wrong port to access CIT Backend. Port **10101** should be used: 

[http://127.0.0.1:10101](http://localhost:10101/#/)

## Problem: The application does not start, error: 'Could not acquire change log lock'

Log command: `docker logs -f "`docker container ls | grep 'code_inventory_backend-app' | awk '{print $NF}'`"`

Logs: Invocation of init method failed; nested exception is liquibase.exception.LockException: Could not acquire change log lock. Currently locked by 192.168.1.4 (192.168.1.4) since 1/4/19 4:38 PM

Cause: Liquibase update was abruptly stopped, so the Liquibase change log lock remained stuck in the database.

Fix: 

    cd [project]
    ./mvnw liquibase:releaseLocks

## **Problem: The application fails to start, error: 'role "code_inventory_grafana" already exists'**

Logs:

CREATE USER code_inventory_grafana WITH PASSWORD]
2019-02-11 23:43:44.196  WARN 1 --- [           main] ConfigServletWebServerApplicationContext : Exception encountered during context initialization - cancelling refresh attempt: org.springframework.context.ApplicationContextException: Unable to start web server; nested exception is java.lang.RuntimeException: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'servletEndpointRegistrar' defined in class path resource [org/springframework/boot/actuate/autoconfigure/endpoint/web/ServletEndpointManagementContextConfiguration$WebMvcServletEndpointManagementContextConfiguration.class]: Bean instantiation via factory method failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [org.springframework.boot.actuate.endpoint.web.ServletEndpointRegistrar]: Factory method 'servletEndpointRegistrar' threw exception; nested exception is org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'auditEventsEndpoint' defined in class path resource [org/springframework/boot/actuate/autoconfigure/audit/AuditEventsEndpointAutoConfiguration.class]: Unsatisfied dependency expressed through method 'auditEventsEndpoint' parameter 0; nested exception is org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'customAuditEventRepository' defined in file [/app/classes/com/veracode/inlab/cit/backend/repository/CustomAuditEventRepository.class]: Unsatisfied dependency expressed through constructor parameter 0; nested exception is org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'persistenceAuditEventRepository': Cannot create inner bean '(inner bean)#58835bba' of type [org.springframework.orm.jpa.SharedEntityManagerCreator] while setting bean property 'entityManager'; nested exception is org.springframework.beans.factory.BeanCreationException: Error creating bean with name '(inner bean)#58835bba': Cannot resolve reference to bean 'entityManagerFactory' while setting constructor argument; nested exception is org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'liquibase' defined in class path resource [com/veracode/inlab/cit/backend/config/LiquibaseConfiguration.class]: Invocation of init method failed; nested exception is liquibase.exception.MigrationFailedException: Migration failed for change set config/liquibase/changelog/20190208183145_changelog.xml::1548366598800-1::andrey :
     Reason: liquibase.exception.DatabaseException: **ERROR: role "code_inventory_grafana" already exists** [Failed SQL: --

Cause: 

Grafana user already exists in the database: code_inventory_grafana. You restored database Backup was made before Grafana user has been created. Therefore, it does not contain 'drop role' statement for that user.

Fix:

1 Close all connections to the database (Grafana, CIT, any Postgres client)

2 Modify the backup file (e.g. dump.sql) you restored the database from to include this statement:

`DROP ROLE code_inventory_grafana;`

3 Restore database from backup

4 Run Code Inventory Backend 

5 Verify the app is running with no errors showing in log

6 Verify the latest changelog has been applied to the database:

**select** * **from** databasechangelog **order** **by** orderexecuted **desc** **limit** 1;

(e.g. 20190211183145_changelog.xml at the moment of the writing)

(The list of changelogs is located in src/main/resources/config/liquibase/**master.xml**)

## **Problem: Error 'Cannot create container...container name...is already in use' when using docker stack**

Command: `docker stack up -c src/main/docker/infra.yml code-inventory`

Errors:

ERROR: for docker_code_inventory_backend-grafana_1 Cannot create container for service code_inventory_backend-grafana: b'Conflict. The container name "/docker_code_inventory_backend-grafana_1" is already in use by container "0e4ddfd7aa1faa6b0c5915c9835b7575555ede56a58451a9713f9fdb9bf9fe5c". You have to remove (or rename) that container to be able to reuse that name.'

Cause: container already exists

Fix: `docker system prune`

## Problem: Error 'Could not attach to network' network ... not found

Command: `docker stack up -c src/main/docker/infra.yml code-inventory`

Output:

ERROR: for docker_code_inventory_backend-postgresql_1 Cannot start service code_inventory_backend-postgresql: Could not attach to network 1f7dd5cd91ca365fc4020e39e45c2cbb6d4067c41db5b8f49baf74f34f9701b3: rpc error: code = NotFound desc = network 1f7dd5cd91ca365fc4020e39e45c2cbb6d4067c41db5b8f49baf74f34f9701b3 not found

ERROR: for code_inventory_backend-postgresql Cannot start service code_inventory_backend-postgresql: Could not attach to network 1f7dd5cd91ca365fc4020e39e45c2cbb6d4067c41db5b8f49baf74f34f9701b3: rpc error: code = NotFound desc = network 1f7dd5cd91ca365fc4020e39e45c2cbb6d4067c41db5b8f49baf74f34f9701b3 not found

ERROR: Encountered errors while bringing up the project.

Cause: this docker network was created by previous runs, but not removed properly

Fix: `docker system prune`

## Problem: Code Inventory fails to start, error: 'Error response from daemon: Bad response from Docker engine'

Command: `./start+logs.sh`

Error:

Error response from daemon: Bad response from Docker engine

CHECKING IF DOCKER SWARM IS AVAILABLE>

Docker swarm not found. Use "docker swarm init" to create a single-node swarm (or "docker swarm join" to connect to existing swarm.)

Cause 1: Docker is not in swarm mode.

Fix: `docker swarm init`

Cause 2: After system restart, it takes some time for the Docker engine to fully start. If CIT is started close to system restart.

Fix: wait several seconds to give Docker chance to complete its startup. Then, retry starting Code Inventory.

## Problem: 'Docker secrets are not available' on CIT startup

Command: `docker-compose -f src/main/docker/app.yml up -d`

Error: 

Docker secrets are not available - you are probably running it wrong. This app requires 1) docker running in swarm mode and 2) be started with docker stack deploy, to have the secrets available. Please check how you start this app.

Cause: now that CIT Backend uses docker secrets, one needs to run CIT Backend with `docker stack up` instead of `docker-compose` command.

Fix: Use `docker stack up` instead of `docker-compose` command to start CIT Backend:

`docker stack up -c src/main/docker/app.yml code-inventory`

## Problem: application fails to start, 'No such container:' error

Command: `./start.sh`

Output: 

Error: No such container:

Cause:The docker log command fails to access the logs of container, because container has not yet fully stated

Fix: Retry starting the application

## Problem: application fails to start, 'failed to create service', 'network code-inventory_default not found' error

Command: `./start.sh`

Output:

Creating service code-inventory_code_inventory_backend-app

**failed to create service** code-inventory_code_inventory_backend-app: Error response from daemon: **network code-inventory_default not found**

-or-

Creating service code-inventory_code_inventory_backend-postgresql

failed to create service code-inventory_code_inventory_backend-postgresql: Error response from daemon: network code-inventory_default not found

Cause: Sometimes after the application has just been stopped, a leftover container or docker network still remains in docker infrastructure.

Fix: 

Give it a clean stop by running `./stop.sh` script

Verify no Code Inventory-specific containers or networks present

`docker container ls`

`docker network ls`

Retry starting the application.

## **Problem: Code Inventory starts, but seems to hang after initial few lines of log output. Last line: 'The application will start in 0s'**

Command: `./start.sh`

Output:

Service code-inventory_code_inventory_backend-postgresql state: new

Picked up _JAVA_OPTIONS: -Xmx512m -Xms256m

The application will start in 0s...

Cause: Docker may be hanging. Verify Docker is not hanging by issuing any Docker command, for instance, `docker container ls`

Docker may seem hanging if there is an excess Docker activity in the system, e.g. ungoing a Docker image CI build.

Fix: address excess Docker activity, if any, and retry.

## Problem: Code Inventory starts, but seems to hang after initial few lines of log output. Last line: 'The following profiles are active'

Command: ./start.sh

Cause: The system may be low on resources, preventing Code Inventory Backend to fully start

Fix: Check if there is excessive consumption of resources (e.g. an ongoing build process). Address resource consumption issue, then retry.

## Problem: Code Inventory Backend logs are not visible/empty/blank

Command: `./logs.backend.sh`

Cause: Code Inventory Backend may have failed to start

Addressing:

Verify Code Inventory Backend container is running:

`docker container ls`

Output:

    CONTAINER ID IMAGE
    [numeric id] vinlab/code-inventory-backend:latest

If Code Inventory Backend container is not present in the output, re-start Code Inventory.

If Code Inventory Backend container is present in the output, it may fail to serve due to excessive consumption of system resources by some other process (see above problem). Address resource consumption issue, then re-start Code Inventory.

# Problems at run time

## **Problem: 'Unauthorized' (401) HTTP status is returned by API call**

Example:

    {
        "type": "https://www.jhipster.tech/problem/problem-with-message",
        "title": "Unauthorized",
        "status": 401,
        "detail": "Full authentication is required to access this resource",
        "path": "/api/configs",
        "message": "error.http.401"
    }

Cause: You need to authenticate.

Fix:

Before using Backend API from your client app/curl/Postman, you need to obtain a JWT token by authenticating into the API. Send a POST request to `[http://127.0.0.1:10101/api/authenticate](http://localhost:8080/api/authenticate)` endpoint and the body as shown:

    POST http://127.0.0.1:10101/api/authenticate
    
    Body:
    {
    	"username":"admin",
    	"password":"admin"
    }

The JWT token will be returned in response body

    {
      "id_token" : "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImF1dGgiOiJST0xFX0FETUlOLFJPTEVfVVNFUiIsImV4cCI6MTU0NjUwMzU5MH0.j_JfHze_gw-ZcpG2_9fCX3s8UR0o-MrS5feakzfuMsrJfcRn2xH9nCeczQCnS7I1fFM2_FUBUOJ_JVyUn9GAHQ"
    }

Now you can add this token to your requests to Backend API:

    Header: Authorization
    Value: Bearer [token]

More info:

## **Problem: 'Unsupported Media Type' (415) HTTP status is returned by API call**

Error:

    {"type":"https://www.jhipster.tech/problem/problem-with-message",
    "title":"Unsupported Media Type","status":415,
    "detail":"Content type 'multipart/form-data;boundary=--------------------------710751256051670950567887;charset=UTF-8' not supported",
    "path":"/api/jobs","message":"error.http.415”}

Cause: Missing/wrong value in header Content-Type

Fix: ensure that Content-Type header has value **application/json**

Note: if using Postman, verify header values by examining request's Curl code:

![](ScreenShot2019-01-07at10-58c91ad5-5da5-4cdd-a629-ffce5be4bdb3.47.55AM.png)

## Problem: 'Transaction was marked for rollback only; cannot commit.' error

Command: `docker logs -f "`docker container ls | grep 'code_inventory_backend-app' | awk '{print $NF}'`"`

Error output: Caused by: org.hibernate.TransactionException: Transaction was marked for rollback only; cannot commit.

Cause: There was an exception during Java execution, which caused the database transaction to be rolled back.

Resolution: Further examine logs/output including 'Cause' exceptions in Java call stacks, for the underlying issue. Example:

    Error: Caused by: 
    org.postgresql.util.PSQLException: ERROR: duplicate key value violates unique constraint "pk_job"  Detail: Key (id)=(2001) already exists.

## Problem: Hibernate generates an already existing value for primary key

Error: Caused by: org.postgresql.util.PSQLException: ERROR: duplicate key value violates unique constraint "pk_job" Detail: Key (id)=(2001) already exists.

Cause: For some reason, Hibernate assigns a key which is already existing in the database.

Example: Hibernate sequence is lagging behind max ID value in database. For example, in a particulare incidense, hibernate sequence has last value of 2000, while in the same time, max Job id in job table is 2003.

Workaround: Repeat the query several times. Each time, Hibernate sequence gets bumped. Eventually, it overcomes the max ID value in the table.

# Problems with Grafana

## **Problem: Grafana does not show any data**

Cause: You haven't ran any Local-Analysis jobs yet

Fix: run local analysis to get the data. Before local analysis, you need to run data sync and code sync.

## **Problem: Grafana does not show some data, for example, for last week**

Cause: You haven't ran any Code-Sync job recently (or after restoring from backup)

Fix: run Code-Sync job followed by Local-Analysis job to get the data

# Usage Problems

## **Problem: Registration confirmation email does not show up in mailbox**

Cause 1: At Veracode, emails get delayed by extra security checks. You can receive the email with more than 24 hour delay. 

Fix: Try using a non-@veracode email for registrations

Cause 2: Mail server misconfiguration at backend

Cause 3: Mail server not available at the moment

Steps to take: 

Start Backend using  `./mvnw` command

Examine the output of `./mvnw` command when creating a user or doing self-registration.

Example error outputs:

    Caused by: javax.mail.AuthenticationFailedException: 534-5.7.14

    Caused by: javax.mail.AuthenticationFailedException: 535 5.7.8 Error: authentication failed: UGFzc3dvcmQ6

Report the findings to Dev/Ops team.

## **Problem: Cannot use [param] filter on API endpoint, error: 'Failed to convert property value of type 'java.lang.String''**

Example URL: [http://127.0.0.1:10101/api/jobs?type=data-sync](http://localhost:10101/api/jobs?type=data-sync)

Error: Failed to convert property value of type 'java.lang.String' to required type 'io.github.jhipster.service.filter.StringFilter' for property 'type'; nested exception is java.lang.IllegalStateException: Cannot convert value of type 'java.lang.String' to required type 'io.github.jhipster.service.filter.StringFilter' for property 'type': no matching editors or conversion strategy found

Cause: Incorrect use of URL parameters in API calls

Resolution:

The correct way is to use [param].[op]= notation:

http://127.0.0.1:10101/api/jobs?type.equals=data-sync

http://127.0.0.1:10101/api/jobs?id.equals=1951

For more info and examples, see API's Swagger interface at [http://127.0.0.1:10101/#/admin/docs](http://localhost:10101/#/admin/docs)

## Problem: In Frontend, it is not possible to synchronize organizations

Symptoms: 'Start Sync' button disabled/greyed out under SCM Organizations.

Cause: The user does not have access to any orgs

# Where is my data?! - Data problems

**Problem: Data-Sync job only creates repos other than directly owned by end-user - no org-repos.**

Cause: The org-sync job marks all Orgs initially as disabled

Fix: Enable the orgs in the database before running Data-Sync job

Problem: Grafana Commit History does not show any data per-app

Cause: After creating an app, one needs to re-run local analysis in order to get the per-app data

Fix: In Frontend, go to Organizations and click Start Sync

# Integration Problems

## Problems integrating with Backend API

Sometimes, you get an error when you are trying to integrate your client with Backend API.

## Before your reach out for help:

- [ ]  Recreate the problem using Backend Web UI: [http://127.0.0.1:10101/#](http://localhost:8080/#/org), or recreate the problem using Swagger UI: [http://127.0.0.1:10101/#/admin/docs](http://localhost:10101/#/admin/docs), or recreate the problem using Postman/Curl.
- [ ]  Collect error outputs from Swagger, Postman or Curl
- [ ]  Collect app and db logs

    # Follow app logs
    `docker logs -f "`docker container ls | grep 'code_inventory_backend-app' | awk '{print $NF}'`"`
    # Follow db logs
    `docker logs -f "`docker container ls | grep 'code_inventory_backend-postgres' | awk '{print $NF}'`"`

- [ ]  Share these outputs with Dev

# Development

The rest of this doc concerns problems arising from development activities

# Problems during Maven build

## Problem: Maven build fails with 'SurefireBooterForkException: There was an error in the forked process' and 'sun.reflect.annotation.TypeNotPresentExceptionProxy' errors.

Command: ./mvnw package -Pprod jib:dockerBuild #build docker app

Cause: something was stuck remediable with maven 'clean' goal

Fix: Problem went away after cleaning with ./mvnw clean

# Problems when building with IDE (Maven build succeeds)

## **Problem: Compiler error: [Entity]_ cannot be resolved to a variable**

Example: Repo_ cannot be resolved to a variable

Command: none (building project in IDE)

Cause: The [Entity]_.java files are generated by JPA Static Metamodel Generator. It is already part of Maven build, but not automatically configured in Eclipse. Follow the steps described  in **Additional IDE setup steps** section above.

# Problems during unit testing

## **Problem: NullPointerException during get[Entity]() tests**

Command: `./mvnw clean test`

Error: **NullPointerException**

    public void getConfig() throws Exception {
    // Initialize the database
    configRepository.saveAndFlush(config);
    // Get the config
    restConfigMockMvc.perform(get("/api/configs/{id}", config.getId()))
    -- null in config.id field

Error: org.springframework.dao.InvalidDataAccessApiUsageException: The given id must not be null!; nested exception is java.lang.IllegalArgumentException: The given id must not be null!

Cause: database did not assign an ID value back to entity, or not save it to database at all!

Cause: Having @Version annotation on a field is known to cause this.

Fix: Remove @Version annotation and retry.

## Problem: test failures with 'Function "UUID_GENERATE_V4" not found'

Error: org.h2.jdbc.JdbcSQLException: Function "UUID_GENERATE_V4" not found

Cause: H2 database does not know about Postgres-specific function uuid_generate_v4()

Fix: for the tests, need to use UUID function which is native to H2. Example: **RANDOM_UUID**

Changes: adding dbms-specific property for UUID function to changeset:

    <property name="uuid_function" value="uid.uuid_generate_v4()" dbms="postgresql" />
    	<property name="uuid_function" value="RANDOM_UUID()" dbms="h2" />
    	<changeSet author="andrey (generated)" id="20181226181215-1">
    		<insert tableName="tenant">
    			<column name="id" valueComputed="${uuid_function}" />
    			<column name="disabled" valueBoolean="false" />
    			<column name="created" valueDate="now()" />
    			<column name="modified" valueDate="now()" />
    		</insert>
    	</changeSet>

# Problems during integration testing

**Problem: NullPointerExpception during get[Entity]() tests**

Command: `./mvnw clean test`

Error: **NullPointerExpception**

    public void getConfig() throws Exception {
    // Initialize the database
    configRepository.saveAndFlush(config);
    // Get the config
    restConfigMockMvc.perform(get("/api/configs/{id}", config.getId()))
    -- null in config.id field

Error: org.springframework.dao.InvalidDataAccessApiUsageException: The given id must not be null!; nested exception is java.lang.IllegalArgumentException: The given id must not be null!

Cause: database did not assign an ID value back to entity, or not save it to database at all.

Cause: Having @Version annotation on a field is known to cause this.

Fix: Remove @Version annotation and retry.

# Startup Problems

**Problem: Error creating bean with name 'jobService': Unsatisfied dependency.**

Error: 

    Error creating bean with name 'jobService': 
    Unsatisfied dependency expressed through field 'assetSyncAlgorithm'; 
    nested exception is org.springframework.beans.factory.NoSuchBeanDefinitionException: 
    No qualifying bean of type 'com.veracode.inlab.cit.backend.AssetSync1Algorithm' available: 
    expected at least 1 bean which qualifies as autowire candidate. 
    Dependency annotations: {@org.springframework.beans.factory.annotation.Autowired(required=true)}

Cause: missing @Component annotation on bean class

# Docker problems

**Problem: 'Error response from daemon' error when trying to login to a docker image**

Command: `docker run -ti --entrypoint bin/sh c7c7212f9202`

Error: docker: Error response from daemon: OCI runtime create failed: container_linux.go:348: starting container process caused "exec: \"bin/sh\": stat bin/sh: no such file or directory": unknown.

Cause: Need to use absolute path for entrypoint

Fixed: docker run -ti --entrypoint **/bin/sh** c7c7212f9202