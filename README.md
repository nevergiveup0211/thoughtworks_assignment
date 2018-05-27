# Thoughtworks assignment


This setup is for bringing up the testing env as detailed in https://www.dropbox.com/s/qrchonesmt0txgn/DevOps_Test.pdf?dl=0


> The results of this setup is not to be viewed as production ready, as it requires further testing in deciding the capacity and monitoring for the infrastructure that needs to be in place.


## Cluster Details

* ubuntu 14.04
* Docker 18.05.0-ce
* docker-compose 1.21.2
* docker swarm (single node cluster where the manager node will be acting as worker as well)


## Assumptions

* Below are a few assumptions for the setup.

```
- assuming a ubuntu linux workstation 
- the setup will be done ove a single node docker swarm cluster
- eth0 will be the default interface for swarm interface
- docker stack name used is companynews
```

## Directory structure

```
thoughtworks_assignment/
├── assumptions
├── docker-compose.yml
├── docker-stack.yml
├── dynamic
│   └── Dockerfile
├── README.md
├── setup.sh
├── static
│   ├── default.conf
│   └── Dockerfile
├── steps
├── test_results
│   ├── ab_with_1_dynamic_1_static
│   ├── ab_with_5_dynamic_1_static
│   ├── ab_with_5_dynamic_3_static
│   └── ab_with_5_dynamic_3_static_and_keep_alive
└── Vagrantfile
```

* docker-stack.yml - the docker swarm stack file
* docker-compose.yml - docker compose file which will be used to build required images or can be used individually as well
* dynamic - contains the docker file for the dynamic app hosting the WAR file on a JETTY server
* static - contains the docker file for the static app hosting the static content on a NGINX server 
* setup.sh - the setup bash script
* test_results - test results with the file name showing the test inputs.
* Vagrantfile - a vagrant file to setup a ubuntu 14.04 iamge 

## Setup and script details

                               +---------------+          +-----------------------------------+
                               |               |          |                                   |
        User requests+--------> Nginx/Haproxy  +--------->  Dynamic content on JETTY server   |
                               |               |          |                                   |
                               +---------------+          +-----------------------------------+


* In a Ubuntu 14/16 box with " git " installed clone this repo

```
git clone https://github.com/krishnaghatti/thoughtworks_assignment.git
```

* The repo " thoughtworks_assignment " has a script " setup.sh " which will be the base for setting up the system.
* Change the current working directly to " thoughtworks_assignment "
* The first time the script is run will check if docker, docker-compose are installed and install them if required.
* Once the first step is complete, user has to log out of the current session and log back in for the group setting to take effect.
* Running the script with out any arguments will give the options available.

```
$ ./setup.sh
setup.sh: script to install and deploy docker containers of static and dynamic content
usage: setup.sh [arg]

Options:

testing    setup the local testing environment
status     shows the docker stack status
swarm      setup local swarm cluster with one node
benchmark  run ab tests
images     list images
```

* For setting up a single node docker swarm:

```
$ ./setup.sh swarm
starting local swarm cluster
....
....
```

* Once the swarm cluster is up and running:

```
$ ./setup.sh swarm
starting local swarm cluster
swarm is already setup
```
* To bring up the test env:

```
$ ./setup.sh testing deploy
```
This will build the required images from the docker compose file provided and save it locally.

* At the end of the deploy, the script outputs the cluster status - the output of "stack ps companynews"

```
ID                  NAME                    IMAGE                                    NODE                       DESIRED STATE       CURRENT STATE                     ERROR                       PORTS
5hthxflo93g5        companynews_static.1    thoughtworks_assignment_static:latest                               Ready               Pending less than a second ago
p1ugfadhqjhj        companynews_dynamic.1   thoughtworks_assignment_dynamic:latest   vagrant-ubuntu-trusty-64   Running             Assigned less than a second ago

```

* Additional options of the script.
```

```

## Production setup

### TL;DR 
```
- Docker swarm for small stups
- Mesos/Marathon or Kubernetes for medium, large and extra large setups requiring high availability. 
```
### A bit more detailed explanation of the production setup

* In case of a small setup where the number of applications is sane, using docker swarm mode in production works fine. 
* Scaling of services in a swarm is straightforward. 
* For scaling one service of a stack in a docker swarm cluster:
```
$ docker service ls
ID                  NAME                  MODE                REPLICAS            IMAGE                                    PORTS
8cf3hgabta06        companynews_dynamic   replicated          1/1                 thoughtworks_assignment_dynamic:latest   *:8080->8080/tcp
sdr94oewv4sq        companynews_static    replicated          1/1                 thoughtworks_assignment_static:latest    *:80->80/tcp

$ docker service scale companynews_dynamic=2
companynews_dynamic scaled to 2
overall progress: 2 out of 2 tasks
1/2: running   [==================================================>]
2/2: running   [==================================================>]
verify: Service converged

$ docker service ls
ID                  NAME                  MODE                REPLICAS            IMAGE                                    PORTS
8cf3hgabta06        companynews_dynamic   replicated          2/2                 thoughtworks_assignment_dynamic:latest   *:8080->8080/tcp
sdr94oewv4sq        companynews_static    replicated          1/1                 thoughtworks_assignment_static:latest    *:80->80/tcp
```  
* Production setup for an application that is targeting 4-9’s availability requires a different take. Managing large clusters with docker swarm becomes a bit tedious.
* Requirements for a production setup:
	* HA for individual components
	* Monitoring/Alerting for Infra componetns
	* Application latency metrics
	* Circuit Breakers for backend/thirdparty systems
	* Ability to scale individual components on demad
* Getting into a bit more details 
	* Both nginx and haproxy are built to handle scale and load.
	* In the current implementation the dynamic content container vhost is defined as the HOST in proxy pass of nginx configuration
	* For scale this can be changed a bit.
		* In case of AWS ECS, we can add a load balancer such as ALB in front of the backend servers distributing the load.
		* Below is another possible setup with Mesos/Marathon

        *                                            +-----------------+         +---------------------+
        *                                            |                 |         |Docker hosts         |
        * User requests +----> DNS Server    +----->   | HAproxy cluster | +-----> |with the applications|
        *                    (AWS Route 53)          |                 |         |                     |
        *                                            +-----------------+         +---------------------+

        * The HAP group is scalable on demand
        * HAP config will have the backends defined per app
        * As and when there is a change in the containers, the HAP config is updated

## What's missing in the script 

* Monitoring
* Centralised Logging
* Application metrics
* Build and CI systems


## References

* Docker swarm in production - https://rock-it.pl/tips-for-using-docker-swarm-mode-in-production/
* Swarm migration from cloud https://docs.docker.com/docker-cloud/migration/cloud-to-swarm/#top--and-sub-level-keys
