#!/bin/bash

docker stop angularapp
docker remove angularapp
# pull fresh image
docker pull hannahwysong/wysong-ceg3120:latest
# run new container by name, with restart automatic
docker run -d -p 80:5000 --name angularapp --restart always hannahwysong/wysong-ceg3120:latest