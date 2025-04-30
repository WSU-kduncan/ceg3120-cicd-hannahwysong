#!/bin/bash
# stop container
docker stop angularapp
# remove container
docker remove angularapp
# pull fresh image
docker pull hannahwysong/wysong-ceg3120:latest
# run new container by name, with restart automatic
docker run -d -p 4200:4200 --name angularapp --restart always hannahwysong/wysong-ceg3120:latest
