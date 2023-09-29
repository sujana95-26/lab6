#!/bin/bash

# Remove running containers

docker rm -f $(docker ps -aq)

# Create network
docker network create trio-task-network

#create a volume
docker volume create new-volume

# Build images
docker build -t trio-task-mysql:5.7 db 
docker build -t trio-task-flask-app:latest flask-app

# Run mysql container
docker run -d \
    --name mysql \
    --network trio-task-network \
    --mount type=volume,source=new-volume,target=/var/lib/mysql \
    trio-task-mysql:5.7

# Run flask-app container
docker run -d \
    -e MYSQL_ROOT_PASSWORD=password \
    --name flask-app \
    --network trio-task-network \
    trio-task-flask-app:latest

# Run nginx container
docker run -d \
    --name nginx \
    -p 80:80 \
    --network trio-task-network \
    --mount type=bind,source=$(pwd)/nginx/nginx.conf,target=/etc/nginx/nginx.conf \
    nginx:latest

# Show running containers
echo    
docker ps -a
