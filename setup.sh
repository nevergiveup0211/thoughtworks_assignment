#!/bin/bash
# setup: script to install and deploy docker containers of static and dynamic content
# Author: Sri Krishna G

# checks and install/setup docker, docker-compose and docker swarm 
AUTHOR="Sri Krishna G"
PROGNAME=`basename $0`
VERSION="0.1.0"

# docker,docker-compose setup
if [ ! -x "$(which docker)" ]; then
    unamestr=`uname` 
    if [[ "$unamestr" != 'Linux' ]]; then
       echo "The script is tested only for Linux flavoured distributions"
       exit
    fi
     
    echo "installing docker-ce"
    docker_cmd=$(which docker)
    if [ $? -ne 0 ]; then
        echo "installing docker. please check the scripts that are downloaded from the web before running on any system !!!"
        curl -sSL https://get.docker.com |sh
        echo;
    fi    
    # update user with docker group. to run docker commands with out sudo
    u="$USER"
    user_cmd=$(getent group docker | grep $u)
    if [ $? -ne 0 ]; then
        sudo usermod -aG docker $u
        echo "please exit the session for the user permission to take effect"
    fi
        
    echo "installing docker-compose"
    compose_test=$(which docker-compose)
    if [ $? -ne 0 ]; then
        sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    sudo apt-get install -y apache2-utils
    echo please logout and relogin so that the group settings
fi

# script help function
print_help() { 
   echo "$PROGNAME: script to install and deploy docker containers of static and dynamic content"
   echo "usage: $PROGNAME [arg]"
   echo
   echo "Options:"
   echo
   echo "testing    setup the local testing environment"
   echo "status     shows the docker stack status"
   echo "swarm      setup local swarm cluster with one node"
   echo "benchmark  run ab tests" 
   echo "images     list images"
   # echo "build     build images"
   exit
}

if [ $# -lt 1 ] || [ "$1" = "help" ]; then
    print_help
    exit 0
fi

# setup swarm
if [ "$1" = "swarm" ]; then  
    echo "starting local swarm cluster"
    swarm_test=$(docker stack ls)
    if [ $? -ne 0 ]; then
        # manager_token=$(docker swarm join-token --quiet manager)
        docker swarm init --advertise-addr eth0
        swarm_init_cmd=$(docker swarm join-token manager | sed -n 3p | sed -e 's/^[ \t]*//')
        $swarm_init_cmd
    else
        echo "swarm is already setup"
    fi
    echo
    exit
fi

# building
# if [ "$1" = "build"]; then  
#     echo "building local images. please be patient as this will take a while..."
#     docker-compose build 
#     exit
# fi

# testing
if [ "$1" = "testing" ]; then
    swarm_test=$(docker stack ls)
    if [ $? -ne 0 ]; then
        echo "swarm is not setup yet. setting up swarm"
        echo "run $PROGNAME swarm"
    fi

	if [ $# -lt 2 ]; then
        echo
        echo "usage : $PROGNAME $1 [ deploy | rm | services ]"
    else
        # building images locally
        echo "building local images. please be patient as this will take a while..."
        docker-compose build 
        if [ "$2" = "deploy" ]; then docker stack deploy --compose-file docker-stack.yml companynews;fi
        if [ "$2" = "rm" ]; then docker stack rm companynews;fi
        if [ "$2" = "services" ]; then docker stack services companynews
        else echo;docker stack ps companynews;fi        
    fi
	echo
    exit
fi    	

# status
if [ "$1" = "status" ]; then
    docker stack ls
	echo;exit
fi      	

# basic testing
if [ "$1" = "testing" ]; then
    echo curl -I -X GET http://localhost/
    curl -I -X GET http://localhost/
	echo;exit
fi

# benchmark
if [ "$1" = "benchmark" ]; then
    echo "ab -k -n 10000 -c 10 http://localhost/"
    ab -k -n 10000 -c 10 http://localhost/
	echo;exit
fi
      	
# images
if [ "$1" = "images" ]; then
    if [ $# -lt 2 ]; then
        echo
        echo "usage : $PROGNAME $1 [ list | rm ]"
    else
        if [ "$2" = "list" ]; then docker images;fi
        if [ "$2" = "rm" ]; then docker rmi `docker images -q`
        else echo; docker images;fi
	echo;exit
    fi
fi    	

# command not matching
echo
(>&2 echo $PROGNAME: UNKNOWN COMMAND [\"$1\"])
print_help
exit
