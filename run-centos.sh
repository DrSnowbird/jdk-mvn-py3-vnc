#!/bin/bash -x

#docker run --rm -it --name=jdk-mvn-py3-vnc --restart=no -e VNC_RESOLUTION=1920x1080 -v /home/user1/data-docker/jdk-mvn-py3-vnc/data:/home/developer/data -v /home/user1/data-docker/jdk-mvn-py3-vnc/workspace:/home/developer/workspace -p 5901:5901 -p 6901:6901 jdk-mvn-py3-vnc-centos
docker run --rm -it --name=jdk-mvn-py3-vnc --restart=no -p 5901:5901 -p 6901:6901 jdk-mvn-py3-vnc-centos

