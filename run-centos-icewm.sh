#!/bin/bash -x

# docker run --rm -it -p 5901:5901 -p 6901:6901 --user $(id -u):$(id -g) consol/centos-xfce-vnc
docker run --rm -it -p 5901:5901 -p 6901:6901 --user $(id -u):$(id -g) jdk-mvn-py3-vnc-centos-icewm

#docker run --rm -it --name=jdk-mvn-py3-vnc --restart=no -e VNC_RESOLUTION=1920x1080 -v /home/user1/data-docker/jdk-mvn-py3-vnc/data:/home/developer/data -v /home/user1/data-docker/jdk-mvn-py3-vnc/workspace:/home/developer/workspace -p 5901:5901 -p 6901:6901 jdk-mvn-py3-vnc-centos
#docker run --shm-size=256m  --rm -it --name=jdk-mvn-py3-vnc-centos-icewm --restart=no -e VNC_PW=vncpassword -e VNC_RESOLUTION=800x600 -p 5901:5901 -p 6901:6901 jdk-mvn-py3-vnc-centos-icewm:latest

#docker run --shm-size=256m  --rm -it --name=docker-headless-vnc-container --restart=no -e VNC_PW=vncpassword -e VNC_RESOLUTION=800x600 -p 5901:5901 -p 6901:6901 openkbs/docker-headless-vnc-container
docker run --rm -it --name=docker-headless-vnc-container -p 5901:5901 -p 6901:6901 openkbs/docker-headless-vnc-container
