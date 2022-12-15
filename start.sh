#!/bin/bash

containerName=local-mkdocs

runningID=$(docker ps | grep $containerName | awk '{print $1}')
if [[ "$runningID" != "" ]];then
    echo "stop $containerName" 
    docker stop $runningID
fi

stoppedID=$(docker ps -a | grep $containerName | awk '{print $1}')
if [[ "$stoppedID" != "" ]];then
    echo "rm $containerName" 
    docker rm $stoppedID
fi

imageID=$(docker images | grep $containerName | awk '{print $3}')
if [[ "$imageID" != "" ]];then
    echo "rmi $containerName" 
    docker rmi $imageID
fi

docker build . -t $containerName

docker run --name=$containerName -p 10000:10000 $containerName /bin/sh  >/dev/null 2>&1 &