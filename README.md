# Thoughtworks assignment


This setup is for bringing up the testing env as detailed in https://www.dropbox.com/s/qrchonesmt0txgn/DevOps_Test.pdf?dl=0


> The results of this setup is not to be viewed as production ready, as it requires further testing in deciding the capacity and monitoring for the infrastructure that needs to be in place.


## Cluster Details

* ubuntu 14.04
* Docker 18.05.0-ce
* docker-compose 1.21.2

## What's Missing

* Monitoring
* Centralised Logging
* Application metrics


## Assumptions

* Below are a few assumptions for the setup.

```
- assuming a ubuntu linux workstation 
- eth0 will be the default interface for swarm interface
- docker stack name used is companynews
```

## Setup and script details

* In a Ubuntu 14/16 box with "git" installed clone this repo

```
git clone https://github.com/krishnaghatti/thoughtworks_assignment.git
```

