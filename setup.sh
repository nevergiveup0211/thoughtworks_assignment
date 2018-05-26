#!/bin/bash
# setup: script to install and deploy docker containers of static and dynamic content
# Author: Sri Krishna G

# checks and install/setup docker, docker-compose and docker swarm 
AUTHOR="Sri Krishna G"
PROGNAME=`basename $0`
VERSION="0.1.0"

if [ ! -x "$(which docker)" ]; then
    unamestr=`uname` 
    if [[ "$unamestr" != 'Linux' ]]; then
       echo "The script is tested only for Linux flavoured distributions"
       exit
    fi
     
    echo "installing docker-ce"
    if [ ! -x "$(which docker)" ]; then
        curl -fsSL get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
    # update user with docker group. to run docker commands with out sudo
    fi

    u="$USER"
    [ ! -x "$(getent group docker | grep $u)" ] && sudo usermod -aG docker $u
        
    echo "installing docker-compose"
    compose_test=$(which docker-compose)
    if [ $? -ne 0 ]; then
        sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    echo "building local images. please be patient as this will take a while..."
    docker-compose build
    # add ab
    sudo apt-get install -y apache2-utils
    echo please logout and relogin so that the group settings 
    exit
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
   exit
}

if [ "$1" = "swarm"]; then  
    echo "starting local swarm cluster"
    swarm_test=$(docker stack ps test)
    if [ $? -ne 0 ]; then
        # manager_token=$(docker swarm join-token --quiet manager)
        docker swarm init --advertise-addr eth0
        swarm_init_cmd=$(docker swarm join-token manager | sed -n 3p | sed -e 's/^[ \t]*//')
        $swarm_init_cmd
    fi
fi

if [ $# -lt 1 ] || [ "$1" = "help" ]; then
    print_help
    exit 0
fi


if [ "$1" = "testing" ]; then
    swarm_test=$(docker stack ps test)
    if [ $? -ne 0 ]; then
        echo "swarm is not setup yet. plese run the below command"
        echo "run $PROGNAME swarm"
    fi
	if [ $# -lt 2 ]; then
        echo
        echo "usage : $PROGNAME $1 [ deploy | rm | services ]"
    else
        echo "building images. this will take a little while...."
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
	echo;exit
fi

# benchmark
if [ "$1" = "bench" ]; then
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

# Unknown
echo
(>&2 echo $PROGNAME: UNKNOWN COMMAND [\"$1\"])
print_help
exit
