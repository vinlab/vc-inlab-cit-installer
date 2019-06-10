# API Document

## Notes

- This is subject to multiple changes, esp in object relationships.
- The "id" field is the id generated by our database.
- The original (source system's) id is "ido".
- The "version" field is provided for handling optimistic concurrency.
- API endpoints are RESTful CRUDs.
- For timestamps (*created*, *modified* etc.) the API returns human-formatted strings, e.g. '2018-12-07T19:14:00Z'
- The *weight* is the weight assigned by end-user, 0-100.
- The *rank* is a rank assigned by an algorithm, 0-100.
- The *sort/sortid* is sort order (avoiding "order" name per SQL-reserved word)

## MODEL ENTITIES

/api/configs

    [
      {
        "id": 43616506,
        "type": "app-config",
    		"properties": [
                {
                    "name": "prop1",
                    "value": "value1"
                },
                {
                    "name": "prop2",
                    "value": "prop2"
                }
            ],
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 24
      },
      {
        "id": 43616507,
        "type": "veracode-config",
    		"properties": [
                {
                    "name": "supported-languages",
                    "value": "Java, Python, Go, Ruby, Kotlin, JavaScript"
                },
    						{
                    "name": "key-secret",
                    "value": "d65f7d70c931d5bf5cd5fcd73e52e8dc833b8cff..."
                },
            ],
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 2
      },
      {
        "id": 43616508,
        "type": "ranker-config",
    		"properties": [
                {
                    "name": "defailt-algorithm",
                    "value": "RA1"
                }
            ],
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 14
      }
    ]

Note: 

1. Although the children entities (properties) are included with the GET response, you cannot change them with POST/PUT, cause it will only affect the parent object.

To make changes to children, use the **/api/config-properties** endpoint described next.

2. DELETE request will automatically delete config's children configProperties.

/api/config-properties

    [
      {
        "id": 43616506,
        "name": "property1",
    		"value": "value1",
    		"config": {
                "id": 1001,
                "type": "app-config",
                "created": "2018-12-05T00:06:58.794Z",
                "modified": "2018-12-05T00:06:58.794Z",
                "version": 1
            }
      },
      {
        "id": 43616507,
        "name": "property2",
    		"value": "value2",
    		"config": {
                "id": 1001,
                "type": "app-config",
                "created": "2018-12-05T00:06:58.794Z",
                "modified": "2018-12-05T00:06:58.794Z",
                "version": 1
            }
      }
    ]

/api/scms

    [
      {
        "id": 43616516,
        "name": "GitHub",
        "type": "GitHub",
        "url": "https://github.com",
        "token": "fb4b759297466f3230e823636cec2043e6938885",
        "disabled": false,
        "checked": true,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "sort": 1,
        "version": 4
      },
      {
        "id": 43616517,
        "name": "GitHub - Enterprise",
        "type": "GitHubEnterprise",
        "url": "https://org.github.com",
        "token": "fb4b759297466f3230e823636cec2043e6938885",
        "disabled": false,
        "checked": true,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "sort": 1,
        "version": 14
      },
      {
        "id": 43616518,
        "name": "Bitbucket",
        "type": "Bitbucket",
        "url": "https://bitbucket.org.com",
        "token": "fb4b759297466f3230e823636cec2043e6938885",
        "disabled": true,
        "checked": true,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "sort": 1,
        "version": 2
      },
      {
        "id": 43616519,
        "name": "GitLab",
        "token": "fb4b759297466f3230e823636cec2043e6938885",
        "type": "GitLab",
        "url": "https://gitlab.org.com",
        "disabled": true,
        "checked": true,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
    	  "created": 1542823833,
        "modified": 1542823833,
        "sort": 1,
        "version": 11
      }
    ]

/api/orgs

    [
      {
        "id": 43616527,
        "ido": 11626503,
        "name": "Veracode-Innovation-Lab",
        "url": "https://api.github.com/orgs/Veracode-Innovation-Lab",
        "scmtype": "GitHub",
        "scm": {
          "id": 43616516,
          "name": "GitHub",
          "type": "GitHub",
          "url": "https://github.com",
          "token": "fb4b759297466f3230e823636cec2043e6938885",
          "disabled": false,
          "checked": true,
          "tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
          "created": 1542823833,
          "modified": 1542823833,
          "sort": 1,
          "version": 4
        },
        "disabled": false,
        "rank": 90,
        "importance": 10,
        "sort": 1,
        "tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      },
      {
        "id": 43616528,
        "ido": 11626504,
        "name": "devsecops-community",
        "url": "https://api.github.com/orgs/devsecops-community",
        "scmtype": "GitHub",
        "scm": {
          "id": 43616516,
          "name": "GitHub",
          "type": "GitHub",
          "url": "https://github.com",
          "token": "fb4b759297466f3230e823636cec2043e6938885",
          "disabled": false,
          "checked": true,
          "tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
          "created": 1542823833,
          "modified": 1542823833,
          "sort": 1,
          "version": 4
        },
        "disabled": false,
        "rank": 80,
        "importance": 1,
        "sort": 2,
        "tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 7
      }
    ]

/api/teams

    [
      {
        "id": 43616577,
        "ido": 11626546,
        "name": "DevTeam",
    		"slug": "devteam",
        "membercount": 3,
        "repocount": 0,
        "url": "https://api.github.com/teams/2975315",
    		"scm": "GitHub"
        "disabled": false,
        "rank": 80,
    		"importance": 1,
        "org": {
          "id": 43616527,
          "name": "Veracode-Innovation-Lab",
          "order": 1,
          "rank": 90,
    			"importance": 10,
          "scm": "GitHub",
          "sort": 1,
          "created": 1542823833,
          "modified": 1542823833,
          "version": 3
        },
        "sort": 2,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 7
      }
    ]

/api/repos

    [
      {
        "id": 43615012,
        "ido": 159556743,
        "name": "vc-inlab-cit-backend",
    		"fullname": "Veracode-Innovation-Lab/vc-inlab-cit-backend",
    		"url": "https://api.github.com/repos/Veracode-Innovation-Lab/vc-inlab-cit-backend",
    		"cloneurl": "https://github.com/Veracode-Innovation-Lab/vc-inlab-cit-backend.git",
    		"scm": "GitHub",
    		"org": {
          "id": 43616527,
    			"ido": 43616516,
          "name": "Veracode-Innovation-Lab",
          "order": 1,
          "rank": 90,
    			"importance": 10,
          "scmtype": "GitHub",
          "sort": 1,
          "created": 1542823833,
          "modified": 1542823833,
          "version": 3
        },
    		"disabled": false,
        "rank": 80,
    		"importance": 10,
        "sortid": 1,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
    		"created": 1542823833,
        "modified": 1542823833,
        "version": 3
      },
      {
        "id": 43615013,
        "ido": 11626505,
        "name": "vc-inlab-cit-scm-mock",
    		"fullname": "Veracode-Innovation-Lab/vc-inlab-cit-scm-mock",
    		"url": "https://api.github.com/repos/Veracode-Innovation-Lab/vc-inlab-cit-scm-mock",
    		"cloneurl": "https://github.com/Veracode-Innovation-Lab/vc-inlab-cit-scm-mock.git",
    		"scm": "GitHub",
        "org": {
          "id": 43616527,
    			"ido": 11626503,
          "name": "Veracode-Innovation-Lab",
          "order": 1,
          "rank": 90,
    			"importance": 1,
          "scmtype": "GitHub",
          "sort": 1,
          "created": 1542823833,
          "modified": 1542823833,
          "version": 3
        },
    		"disabled": false,
        "rank": 73,
    		"importance": 10,
        "sortid": 2,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
    		"created": 1542823833,
        "modified": 1542823833,
        "version": 7
      },
      {
        "id": 43615014,
        "ido": 159226175,
        "name": "vc-inlab-parent-pom",
    		"fullname": "Veracode-Innovation-Lab/vc-inlab-parent-pom",
    		"url": "https://api.github.com/repos/Veracode-Innovation-Lab/vc-inlab-parent-pom",
    		"cloneurl": "https://github.com/Veracode-Innovation-Lab/vc-inlab-parent-pom.git",
    		"scm": "Bitbucket",
        "org": {
          "id": 43616527,
          "name": "Veracode-Innovation-Lab",
          "order": 1,
          "rank": 90,
    			"importance": 1,
          "scmtype": "GitHub",
          "sort": 1,
          "created": 1542823833,
          "modified": 1542823833,
          "version": 3
        },
    		"disabled": false,
        "rank": 70,
    		"importance": 10,
        "sort": 3,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
    		"created": 1542823833,
    	  "modified": 1542823833,
        "version": 18
      }
    ]

/api/tags

> Serves app and geo tagging

    [
      {
        "id": 43615701,
    		"type": "app",
        "name": "App1",
    		"description": "App description",
        "repos": [
          {
            
          },
          {
            
          }
        ],
    		"disabled": false,
    		"rank": 90,
    		"weight": 90,
        "sort": 1,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      },
      {
        "id": 43615702,
    		"type": "geo",
        "name": "Region-1",
    		"description": "The Americas",
        "repos": [
          {
            
          },
          {
            
          }
        ],
    		"disabled": false,
        "rank": 70,
        "weight": 50,
        "sort": 2,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      }
    ]

- Allowed values for *type* field are: 'app', 'geo'.
- To tag a repo with a tag: see this FAQ entry:
[Tagging](../faq/faq.md#tagging)

/api/algorithms

Algorithm configurations for syncing, analysis, ranking, reporting etc.

    [
    	{
        "id": 51115113,
        "type": "asset-syncher",
        "name": "Assetsync-1",
        "slug": "assetsync-1",
        "description": "Default algorithm for asset synching",
        "invocation": "shell",
        "command": "java --jar /algorithms/asset-syncher.assetsync-1.jar ${backend-url} ${job-id}",
        "properties": [
          {
            "name": "scm-timeout-seconds",
            "value": "30"
          },
          {
            "name": "repo-timeout-seconds",
            "value": "60"
          }
        ],
        "disabled": false,
        "weight": 50,
        "sort": 1,
        "tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      }, 
    	{
        "id": 51115114,
        "type": "metric-syncher",
        "name": "Metricsync-1",
        "slug": "metricsync-1",
        "description": "Default algorithm for metric synching",
        "invocation": "shell",
        "command": "java --jar /algorithms/metric-syncher.metricsync-1.jar ${backend-url} ${job-id}",
        "properties": [
          {
            "name": "scm-timeout-seconds",
            "value": "30"
          },
          {
            "name": "repo-timeout-seconds",
            "value": "60"
          }
        ],
        "disabled": false,
        "weight": 50,
        "sort": 1,
        "tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      },
    	{
        "id": 51115115,
        "type": "code-syncher",
        "name": "Codesync-1",
        "slug": "codesync-1",
        "description": "Default algorithm for code synching",
        "invocation": "shell",
        "command": "java --jar /algorithms/code-syncher.codesync-1.jar ${backend-url} ${job-id}",
        "properties": [
          {
            "name": "git-clone-params",
            "value": ""
          },
          {
    				"name": "git-pull-params",
            "value": ""
          }
        ],
        "disabled": false,
        "weight": 50,
        "sort": 1,
        "tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      },
    	{
        "id": 51115116,
        "type": "analyzer",
        "name": "Analyser-1",
        "slug": "analyzer-1",
        "description": "Default algorithm for local analysis",
        "invocation": "shell",
        "command": "java --jar /algorithms/analyzer.analyzer-1.jar ${backend-url} ${job-id}",
        "properties": [
    			{
            "name": "all-metrics",
    	        "value": "language, lines-of-code, size-k, total-contributors, commits, prs"
          },
    			{
            "name": "disabled-metrics",
            "value": "none"
          },
    			{
            "name": "time-series-metrics",
            "value": "commits, prs"
          },
    			{
            "name": "time-series",
            "value": "week, month, year"
          }
        ],
        "disabled": false,
        "weight": 50,
        "sort": 1,
        "tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      },
    	{
    	  "id": 51115117,
    	  "type": "aggregator",
    	  "name": "Aggregator-1",
    	  "slug": "Aggregator-1",
    	  "description": "Default aggregation algorithm",
    	  "invocation": "internal",
    	  "command": "java --jar /algorithms/aggregator.aggregator-1.jar ${backend-url} ${job-id}",
    	  "properties": [
    			{
    	      "name": "commits[]",
    	      "value": "commits[name:]"
    	    },
    	    {
    	      "name": "commits[name:commits-by-(.*)].value",
    	      "value": "commits[name:commits-by-$1].value[$1:]"
    	    },
    	    {
    	      "name": "contributors[]",
    	      "value": "contributors[name:]"
    	    },
    	    {
    	      "name": "contributors[name:].value[]",
    	      "value": "contributors[name:].value[committeremail:]"
    	    },
    	    {
    	      "name": "metrics[]",
    	      "value": "metrics[name:]"
    	    },
    	    {
    	      "name": "linesofcode[]",
    	      "value": "linesofcode[language:]"
    	    }
    		],
    	  "disabled": false,
    	  "weight": 50,
    	  "sort": 1,
    	  "tenant": "b1e657e2-0c71-4849-a8c4-f27777d101d9",
    	  "created": "2019-02-21T19:43:22.874Z",
    	  "modified": "2019-02-21T19:43:22.874Z",
    	  "version": 1
    	},
      {
        "id": 51115118,
        "type": "ranker",
        "name": "Ranker-1",
        "slug": "anker-1",
        "description": "Default ranking algorithm",
        "invocation": "shell",
        "command": "java --jar /algorithms/ranker.raanker-1.jar ${backend-url} ${job-id}",
        "properties": [
    			{
            "name": "define size",
            "value": "size-k"
          },
          {
            "name": "define contributors",
            "value": "total-contributors"
          },
          {
            "name": "define commit-frequency",
            "value": "commits-in-last-week"
          },
    			{
            "name": "define pr-frequency",
            "value": "prs-in-last-month"
          },
          {
            "name": "language-weight",
            "value": "10"
          },
          {
            "name": "size-weight",
            "value": "50"
          },
          {
            "name": "contributors-weight",
            "value": "50"
          },
    			{
            "name": "commit-frequency-weight",
            "value": "50"
          },
    			{
            "name": "pr-frequency-weight",
            "value": "90"
          },
    			{
            "name": "language-weights",
            "value": "Java: 60, Kotlin: 60, Go: 70, Python: 40"
          }
        ],
        "disabled": false,
        "weight": 50,
        "sort": 1,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      }
    ]

Note: 

1. Similarly to the /configs endpoint, despite the children entities (properties) being included with the GET responses, you cannot change them using POST/PUT - because this will only affect the parent object. To make changes to the children, use the **/api/algorithm-properties** endpoint described next.

2. DELETE request will automatically delete algorithm properties, no extra call needed.

/api/algorithm-properties

    [
      {
        "id": 43616596,
        "name": "language-weight",
    		"value": "10"
    		"algorithm": {
                ...
            }
      },
    	{
        "id": 43616597,
        "name": "size-weight",
    		"value": "10"
    		"algorithm": {
                ...
            }
      },{
        "id": 43616598,
        "name": "commit-activity-weight",
    		"value": "10"
    		"algorithm": {
                ...
            }
      },  {
        "id": 43616599,
        "name": "exchange-activity-weight",
    		"value": "50",
    		"algorithm": {
            }
      }
    ]

## JOBS

Perform job invocations for Data Sync, Code Sync, Analysis, Ranking, Reports.

> To execute various features of the system - Data Sync, Code Sync, Local Analysis, Ranker, Reports - create a job record using /jobs endpoint.

- Create a record of appropriate job type, and status equal to 'created'.
- The API will return the job id.
- The backend will start the job.
- Use job id and *percentdone* to monitor job progress.
- Use *lastheardfrom* to discover and deactivate stale jobs.
- User *refreshed* field to make the job pick up new data - that is, the data inserted into database after the job has started. To do so, update the job record with *refreshed* field set to current time.
- Some fields below show 'null' value. This is for illustration purposes only - in actual response JSON, these fields will be omitted.
- *Total* means how many objects were encountered. *Processed* means how many objects have been successfully processed.
- Job *status* is one of 'created', 'ongoing', 'completed' (processed at least some items, with or without errors), 'failed' (completely failed), 'abandoned' (marked as stale by housekeeping). The *message* field further clarifies e.g. reads 'Completed with errors' in case of job has completed with errors.

/api/jobs

    [
    	{
        "id": 43615770,
    		"type": "data-sync",
    		"slug": "20181211015138-data-sync",
    		"active": false,
    		"status": "completed",
    		"message": "Success",
    		"processed": 35,
    		"total": 35,
    		"currentitem": null,
    		"percentdone": 100,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
    		"started": 1542823800,
    		"refreshed": 1542823820,
    		"finished": 1542823833,
    		"lastheardfrom": 1542823833,
        "created": 1542823800,
        "modified": 1542823833,
    		"version": 12
      },
    	{
        "id": 43615773,
    		"jobtype": "code-sync",
    		"slug": "20181211015138-code-sync",
    		"active": true,
    		"status": "ongoing",
    		"message": null,
    		"processed": 30,
    		"total": 35,
    		"currentitem": "Veracode-Innovation-Lab/vc-inlab-cit-backend",
    		"percentdone": 80,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
    		"started": 1542823000,
    		"refreshed": 1542823030,
    		"finished": null,
    		"lastheardfrom": 1542823033,
        "created": 1542823000,
        "modified": 1542823033,
    		"version": 10
      },
    	{
        "id": 43615791,
    		"type": "local-analysis",
    		"slug": "20181211015138-local-analysis",
    		"active": true,
    		"status": "ongoing",
    		"message": null,
    		"processed": 11,
    		"total": 35,
    		"currentitem": "Veracode-Innovation-Lab/vc-inlab-cit-frontend",
    		"percentdone": 35,
    		"started": 1542825000,
    		"refreshed": 1542825005,
    		"finished": null,
    		"lastheardfrom": 1542823224,
        "created": 1542825000,
        "modified": 1542823224,
    		"version": 4
      },
    	{
        "id": 43615791,
    		"type": "ranking",
    		"slug": "20181211015138-ranking",
    		"active": true,
    		"status": "ongoing",
    		"message": null,
    		"processed": 3,
    		"total": 35,
    		"percentdone": 10,
    		"currentitem": "Veracode-Innovation-Lab/vc-inlab-cit-assembly",
    		"started": 1542823220,
    		"refreshed": 1542823222,
    		"finished": null,
    		"lastheardfrom": 1542823224,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823210,
        "modified": 1542823224,
    		"version": 2
      },
    	{
        "id": 43615791,
    		"type": "reporting",
    		"slug": "20181211015138-reporting",
    		"active": true,
    		"status": "ongoing",
    		"message": null,
    		"processed": 9,
    		"total": 10,
    		"currentitem": "Veracode-Innovation-Lab/vc-inlab-cit-docs",
    		"percentdone": 90,
    		"started": 1542823220,
    		"refreshed": 1542823223,
    		"finished": null,
    		"lastheardfrom": 1542823224,
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823210,
        "modified": 1542823224,
    		"version": 5
      }
    ]

- The /jobs endpoint accepts sorting and filtering parameters:
    - most recent jobs: 
    /api/jobs?sort=**id,desc**
    - most recent jobs of type: 
    /api/jobs?sort=id,desc&**type.equals=local-analysis**
    - most recent jobs of type and status:
    /api/jobs?sort=id,desc&type.equals=local-analysis&**status.equals=completed**
    - the most recent job of type and status:
    /api/jobs?sort=id,desc&type.equals=local-analysis&status.equals=completed&**size=1**

## FREE-FORM JSON

Allows for storage and modification of free-form JSON documents. In particular, stores the results of executed jobs (scraping, analysis, rankings, reports). You can also use this endpoint to store anything that does not fit anywhere else in the model.

> This endpoint does not use foreign keys - just plain JSONs. That means that anything referred as a sub-object is a snapshot from the point of time when the record was created. In this sense, the records behave similarly to paper documents, i.e. do not change when the underlying objects change.

For example, the content of job sub-object below will not change if/when any changes happen to the original job entity:

/api/records

    [
      {
        "id": 51115002,
        "type": "code-sync",
        "doc": {
    			"id": 51115002,
          "type": "code-sync",
          "counts": [
            {
              "repos": "19",
              "cloned": "1",
              "pulled": "18"
            }
          ],
          "job": {
            "id": 43615791,
    				"slug": "20181211015138-code-sync",
            "type": "code-sync",
            "active": false,
            "status": "completed",
    				"message": null,
    				"processed": 30,
    				"total": 35,
    				"currentitem": "Veracode-Innovation-Lab/vc-inlab-cit-backend",
            "percentdone": 100,
    				"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
            "started": 1542825000,
    				"refreshed": 1542823030,
            "finished": 1542823224,
    				"lastheardfrom": 1542823224,
            "created": 1542825000,
            "modified": 1542823224,
            "version": 4
          }
        },
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      }
    ]

- Internally, the *doc* field is stored in Postgres JSON-optimized JSOB type column.
- This '*doc*' column is indexed by 'id' and 'id'+'type' for fast retrieval.
- Similarly to regular database inserts, you don't need to specify the value for JSON's [doc.id](http://doc.id) when creating a record. It will be populated by the back-end upon record creation, similarly to the relational *id* field, and will receive the same value.

## LOCAL ANALYSIS

/api/records?type.equals=local-analysis

    [
      {
        "id": 51115002,
        "type": "local-analysis",
        "doc": {
          "id": 51115002,
          "type": "local-analysis",
    			"subtype": "git-repo",
          "sha": "89d3d2ffe5338c56fd317d74a166b62e72129b39",
          "repo": {
            "id": 43615012,
            "ido": 159556743,
            "name": "vc-inlab-cit-backend",
            "fullname": "Veracode-Innovation-Lab/vc-inlab-cit-backend",
            "url": "https://api.github.com/repos/Veracode-Innovation-Lab/vc-inlab-cit-backend",
            "cloneurl": "https://github.com/Veracode-Innovation-Lab/vc-inlab-cit-backend.git",
            "scm": "GitHub",
            "org": {
              "id": 43616527,
              "ido": 43616516,
              "name": "Veracode-Innovation-Lab",
              "order": 1,
              "rank": 90,
              "scmtype": "GitHub",
              "sort": 1,
              "created": 1542823833,
              "modified": 1542823833,
              "version": 3
            },
            "disabled": false,
            "rank": 80,
            "sort": 1,
            "created": 1542823833,
            "modified": 1542823833,
            "version": 3
          },
          "metrics": [
            {
              "name": "language",
              "value": "Java"
            },
            {
              "name": "size-k",
              "value": 1024
            },
            {
              "name": "total-contributors",
              "value": 12
            },
            {
              "name": "commits-in-last-1-week",
              "value": 29
            },
    				{
              "name": "commits-in-last-2-weeks",
              "value": 29
            },
            {
              "name": "commits-in-last-1-month",
              "value": 90
            },
            {
              "name": "commit-frequency",
              "value": 29.0
            },
            {
              "name": "prs-in-last-1-week"
    					"value": 0
            },
            {
              "name": "prs-in-last-2-weeks",
              "value": 7
            },
            {
              "name": "prs-in-last-1-month",
              "value": 18
            },
            {
              "name": "avg-prs-having-at-least-3-comments-in-last-5-days",
              "value": 1
            },
            {
              "name": "avg-prs-having-at-least-3-comments-in-last-30-days",
              "value": 4
            },
            {
              "name": "code-complexity",
              "value": 8
            }
          ],
          "job": {
            "id": 43615791,
            "type": "local-analysis",
            "active": false,
            "status": "completed",
            "percentdone": 100,
            "started": 1542825000,
            "finished": 1542823224,
            "lastheardfrom": 1542823224,
            "created": 1542825000,
            "modified": 1542823224,
            "version": 4
          },
          "algorithm": {
            "id": 51115116,
            "type": "analyzer",
            "name": "Analyser-1",
            "slug": "analyzer-1",
            "description": "Default algorithm for local analysis",
            "invocation": "shell",
            "command": "java --jar /algorithms/analyzer.analyzer-1.jar ${backend-url} ${job-id}",
            "properties": [
              {
                "name": "all-metrics",
                "value": "language, line-numbers, repo-size-k, commits, prs"
              },
              {
                "name": "disabled-metrics",
                "value": "line-numbers"
              },
              {
                "name": "time-series-metrics",
                "value": "commits, prs"
              },
              {
                "name": "time-series",
                "value": "1 week, 2 weeks, 1 month"
              }
            ],
            "disabled": false,
            "weight": 50,
            "sort": 1,
            "tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
            "created": 1542823833,
            "modified": 1542823833,
            "version": 1
          }
        },
        "tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      }
    ]

- The /records endpoint accepts JSON path/value parameter, '*doc.contains'*:
    - records created by specific job:
    /api/records?type.equals=local-analysis&**doc.contains=job.id=3751**
    - multiple criteria: records created by specific job, for specific repo:
    /api/records?type.equals=local-analysis&**doc.contains=job.id=3751**&**doc.contains=repo.id=3467
    Note:** the multiple JSON path/value pairs, if specified, are joined by logical **AND** operation
    - records of subtype 'git-global'
    /api/records?type.equals=local-analysis&doc.contains=**subtype=git-global**

## RANKER RESULTS

> The ranks are stored here, as well as directly written into each Repository entity's "rank" field.

/api/records?type.equals=ranker-results

    [
      {
        "id": 51115002,
        "type": "ranker-results",
        "doc": {
    			"id": 51115002,
          "type": "ranker-results",
          "rankings": [
            {
              "repoid": 43615012,
              "algorithmid": 51115117,
              "rank": 80
            },
            {
              "repoid": 43615013,
              "algorithmid": 51115119,
              "rank": 73
            },
            {
              "repoid": 43615014,
              "algorithmid": 51115117,
              "rank": 70
            },
            {
              "repoid": 43615015,
              "algorithmid": 51115119,
              "rank": 65
            },
            {
              "repoid": 43615016,
              "algorithmid": 51115117,
              "rank": 60
            },
            {
              "repoid": 43615017,
              "algorithmid": 51115119,
              "rank": 50
            }
          ],
          "job": {
            "id": 43615791,
            "type": "ranking",
            "active": false,
            "status": "completed",
            "percentdone": 100,
            "started": 1542823220,
            "finished": 1542823224,
            "lastheardfrom": 1542823224
            "created": 1542823210,
            "modified": 1542823224,
            "version": 2
          }
        },
        "scm": "GitHub",
    		"tenant": "7f9c84ed-c4cf-48e2-8825-80ef286c18ca",
        "created": 1542823833,
        "modified": 1542823833,
        "version": 1
      }
    ]