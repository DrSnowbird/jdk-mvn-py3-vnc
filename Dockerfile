# This Dockerfile is used to build an headles vnc image based on Ubuntu

#### -------------------------------------------
#### ---- OS Type, Version, and Base Image: ----
#### -------------------------------------------

#ARG OS_TYPE={OS_TYPE:-centos}
ARG OS_TYPE={OS_TYPE:-ubuntu}

#ARG OS_VERSION={OS_VERSION:-7}
ARG OS_VERSION={OS_VERSION:-16.04}

ARG BASE_IMAGE=${BASE_IMAGE:-${OS_TYPE}:${OS_VERSION}}

#FROM centos:7
#FROM ubuntu:16.04
FROM openkbs/jdk-mvn-py3
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

#### -------------------------
#### ---- user: developer ----
#### -------------------------
ENV USER=${USER:-developer}
ENV USER_NAME=${USER}

ENV HOME=/home/${USER}

ENV OS_TYPE=${OS_TYPE}

#RUN set -x && \
#    if [ "${OS_TYPE}" = "ubuntu" ]; then \
#        apt-get install -y sudo; \
#        apt-get clean -y all; \
#    fi
#RUN set -x && \
#    if [ "${OS_TYPE}" = "centos" ]; then \
#        \yum install -y sudo; \
#        yum clean -y all; \
#    fi"

## -- Ubuntu --
RUN apt-get install -y sudo && apt-get clean all

## -- Centos --
#RUN yum install -y sudo && yum clean all

RUN echo "USER =======> ${USER}"

RUN groupadd ${USER} && useradd ${USER} -m -d ${HOME} -s /bin/bash -g ${USER} && \
    ## -- Ubuntu -- \
    usermod -aG sudo ${USER} && \
    ## -- Centos -- \
    #usermod -aG wheel ${USER} && \
    echo "${USER} ALL=NOPASSWD:ALL" | tee -a /etc/sudoers && \
    chown ${USER}:${USER} -R ${HOME}

##################################
#### Set up user environments ####
##################################
USER ${USER}
WORKDIR ${HOME}

ENV WORKSPACE=${HOME}/workspace
ENV DATA=${HOME}/data

#VOLUME ${WORKSPACE}
#VOLUME ${DATA}

RUN echo "USER =======> ${USER}"

RUN mkdir -p ${WORKSPACE} ${DATA} 

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

### Install custom fonts for Ubuntu only
#RUN ${INST_SCRIPTS}/install_custom_fonts.sh
RUN if [ "${OS_TYPE}" = "ubuntu" ]; then ${INST_SCRIPTS}/install_custom_fonts.sh; fi

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN ${INST_SCRIPTS}/tigervnc.sh
RUN ${INST_SCRIPTS}/no_vnc.sh

### Install firefox and chrome browser
RUN ${INST_SCRIPTS}/firefox.sh
RUN ${INST_SCRIPTS}/chrome.sh

### Install WINDOW_MANAGER (xfce or icewm) UI
RUN ${INST_SCRIPTS}/${WINDOW_MANAGER}_ui.sh
ADD ./src/common/${WINDOW_MANAGER}/ ${HOME}/

### configure startup
RUN ${INST_SCRIPTS}/libnss_wrapper.sh
ADD ./src/common/scripts ${STARTUPDIR}
RUN ${INST_SCRIPTS}/set_user_permission.sh ${STARTUPDIR} ${HOME}

#### --------------------------
#### ---- XDG Open Utility ----
#### --------------------------
RUN apt-get install -y xdg-utils --fix-missing

##################################
#### ---- VNC Startup ---- ####
##################################
WORKDIR ${HOME}

USER ${USER}

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]

# CMD ["--wait"]

## ---- Debug Use ----
CMD ["/bin/bash"]
# (or)
#COPY ./test/say_hello.sh $HOME/
#RUN sudo chmod +x $HOME/say_hello.sh
#CMD "$HOME/say_hello.sh"
