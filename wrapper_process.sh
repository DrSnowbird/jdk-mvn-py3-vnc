#!/bin/bash

echo "####################### Main Process: $(basename $0) ###########################"

printenv

echo ">>>> Who am i: `whoami` ; UID=`id -u` ; GID=`id -g`"

#### Do some process calls here ... ####
/usr/scripts/printVersions.sh

#/bin/bash 

/usr/bin/google-chrome

tail -f /dev/null
