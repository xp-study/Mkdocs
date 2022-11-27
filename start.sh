#!/bin/bash
result=$(docker ps | grep "mkdocs")
if [[ "$result" != "" ]];then
    echo "stop mkdocs" 
    docker stop mkdocs
fi

result1=$(docker ps -a | grep "mkdocs")
if [[ "$result1" != "" ]];then
    echo "rm mkdocs" 
    docker rm mkdocs
fi

result2=$(docker images | grep "mkdocs")
if [[ "$result2" != "" ]];then
    echo "rmi mkdocs" 
    docker rmi mkdocs
fi

docker build . --tags mkdocs:latest

docker run -itd -p 10000:10000 --name mkdocs mkdocs:latest