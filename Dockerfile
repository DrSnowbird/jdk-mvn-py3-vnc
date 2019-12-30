# This Dockerfile is used to build an headles vnc image based on Ubuntu

#### -------------------------------------------
#### ---- OS Type, Version, and Base Image: ----
#### -------------------------------------------

#ARG OS_TYPE={OS_TYPE:-centos}
ARG OS_TYPE={OS_TYPE:-ubuntu}

#ARG OS_VERSION={OS_VERSION:-7}
#ARG OS_VERSION={OS_VERSION:-16.04}
ARG OS_VERSION={OS_VERSION:-18.04}

ARG BASE_IMAGE=${BASE_IMAGE:-${OS_TYPE}:${OS_VERSION}}

#FROM centos:7
#FROM ubuntu:16.04
FROM openkbs/jdk-mvn-py3
#FROM openkbs/jdk-mvn-py3
#FROM ${BASE_IMAGE}
#FROM ${OS_TYPE}:${OS_VERSION}

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

#### ---------------------
#### ---- USER, GROUP ----
#### ---------------------
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}

#### --------------------------------------------------
#### ---- Connection ports for controlling the UI: ----
#### --------------------------------------------------
## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://<IP>:6901/?password=vncpassword

ENV DISPLAY=${DISPLAY:-":1"}

ENV VNC_PORT=${VNC_PORT:-"5901"}
ENV NO_VNC_PORT=${NO_VNC_PORT:-"6901"}

EXPOSE ${VNC_PORT}
EXPOSE ${NO_VNC_PORT}

#### ---------------------------------------
#### ---- Window Manager: xfce or icewm ----
#### ---------------------------------------
ENV WINDOW_MANAGER=${WINDOW_MANAGER:-xfce}

LABEL io.k8s.description="Headless VNC Container with ${WINDOW_MANAGER} window manager, firefox and chromium" \
      io.k8s.display-name="Headless VNC Container based on ${OS_TYPE}" \
      io.openshift.expose-services="${NO_VNC_PORT}:http,${VNC_PORT}:xvnc" \
      io.openshift.tags="vnc, ${OS_TYPE}, ${WINDOW_MANAGER}" \
      io.openshift.non-scalable=true

##################################
#### ---- VNC / noVNC ----    ####
##################################

ENV TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=${HOME}/install \
    NO_VNC_HOME=${HOME}/noVNC \
    VNC_COL_DEPTH=24 \
    VNC_VIEW_ONLY=false

USER 0
WORKDIR ${HOME}

### Install CA certificates:
RUN apt-get install -y ca-certificates 
ADD ./certificates /certificates
RUN ${SCRIPT_DIR}/setup_system_certificates.sh

#### -----------------------------------------------------------------
#### ---- VNC Resolution (1280x1024, 1600x1024, 1920x1280, etc.): ----
#### -----------------------------------------------------------------
#ENV VNC_RESOLUTION=${VNC_RESOLUTION:-1280x1024}
#ENV VNC_RESOLUTION=${VNC_RESOLUTION:-1600x800}
ENV VNC_RESOLUTION=${VNC_RESOLUTION:-1920x1080}

#### ----------------------
#### ---- VNC Password ----
#### ----------------------
ENV VNC_PW=${VNC_PW:-vncpassword}

### Add all install scripts for further steps
ADD ./src/common/install/ ${INST_SCRIPTS}/
ADD ./src/ubuntu/install/ ${INST_SCRIPTS}/
RUN find ${INST_SCRIPTS} -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN ${INST_SCRIPTS}/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install custom fonts for Ubuntu only, 
### For CentOS, it will be no-op (do nothing)
#RUN ${INST_SCRIPTS}/install_custom_fonts.sh

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN ${INST_SCRIPTS}/tigervnc.sh
RUN ${INST_SCRIPTS}/no_vnc.sh

### Install firefox browser
# RUN ${INST_SCRIPTS}/firefox.sh
RUN apt-get install -y firefox

#### ============================================
#### ---- Google-Chrome install:  ----
#### ============================================
RUN ${INST_SCRIPTS}/google-chrome.sh 
    
#### ------------------------------------------------
#### ---- Desktop setup (Google-Chrome, Firefox) ----
#### ------------------------------------------------
ADD ./config/Desktop $HOME/

### Install WINDOW_MANAGER (xfce or icewm) UI
RUN apt-get --fix-missing update
RUN ${INST_SCRIPTS}/${WINDOW_MANAGER}_ui.sh
ADD ./src/common/${WINDOW_MANAGER}/ ${HOME}/

### configure startup
# (remove this when Ubuntu 18.04 Bionic)
# RUN ${INST_SCRIPTS}/libnss_wrapper.sh
ADD ./src/common/scripts ${STARTUPDIR}
RUN ${INST_SCRIPTS}/set_user_permission.sh ${STARTUPDIR} ${HOME}

#### --------------------------
#### ---- XDG Open Utility ----
#### --------------------------
RUN apt-get install -y xdg-utils --fix-missing

#### -------------------------------------
#### ---- Reset Owner and Permissions ----
#### -------------------------------------
RUN chmod a+x /dockerstartup/vnc_startup.sh && \
    mkdir ${HOME}/.local && \
    chown -R ${USER}:${USER} ${HOME}/.config ${HOME}/.local

#################################################################
#### ---- Fix missing: /host/run/dbus/system_bus_socket ---- ####
#################################################################
RUN sudo mkdir -p /host/run/dbus/system_bus_socket

###############################
#### ---- VNC Startup ---- ####
###############################

WORKDIR ${HOME}

USER ${USER}

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]

ADD ./wrapper_process.sh $HOME/

# CMD ["--wait"]

## ---- Debug Use ----
#CMD ["/bin/bash"]
CMD "$HOME/wrapper_process.sh"

# (or)
#COPY ./test/say_hello.sh $HOME/
#RUN sudo chmod +x $HOME/say_hello.sh
#CMD "$HOME/say_hello.sh"
