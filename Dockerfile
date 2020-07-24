# This Dockerfile is used to build an headles vnc image based on Centos

#### -------------------------------------------
#### ---- OS Type, Version, and Base Image: ----
#### -------------------------------------------

ARG BASE_IMAGE=centos:7
#ARG BASE_IMAGE=ubuntu:16.04
#ARG BASE_IMAGE=openkbs/jdk-mvn-py3

FROM ${BASE_IMAGE:-centos:7}

LABEL io.k8s.description="Headless VNC Container with IceWM window manager, firefox and chromium" \
      io.k8s.display-name="Headless VNC Container based on Centos" \
      io.openshift.expose-services="6901:http,5901:xvnc" \
      io.openshift.tags="vnc, centos, xfce" \
      io.openshift.non-scalable=true

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
ENV VNC_PORT=${VNC_PORT:-5901}
ENV NO_VNC_PORT=${NO_VNC_PORT:-6901}

EXPOSE ${VNC_PORT}
EXPOSE ${NO_VNC_PORT}

#### ---------------------------------------
#### ---- Window Manager: xfce or icewm ----
#### ---------------------------------------
#ENV WINDOW_MANAGER=${WINDOW_MANAGER:-icwm}
ENV WINDOW_MANAGER=${WINDOW_MANAGER:-xfce}

#### -------------------------
#### ---- user: developer ----
#### -------------------------
ENV USER=${USER:-developer}
ENV USER_NAME=${USER}

ENV HOME=/home/${USER}

## -- Ubuntu --
#RUN apt-get install -y sudo && apt-get clean all

## -- Centos --
RUN yum update -y && yum install -y sudo && yum clean all

RUN echo "USER =======> ${USER}"

RUN groupadd ${USER} && useradd ${USER} -m -d ${HOME} -s /bin/bash -g ${USER} && \
    ## -- Ubuntu -- \
    #usermod -aG sudo ${USER} && \
    ## -- Centos -- \
    usermod -aG wheel ${USER} && \
    echo "${USER} ALL=NOPASSWD:ALL" | tee -a /etc/sudoers && \
    chown ${USER}:${USER} -R ${HOME}

##################################
#### Set up user environments ####
##################################
USER ${USER}
WORKDIR ${HOME}

ENV WORKSPACE=${HOME}/workspace
ENV DATA=${HOME}/data

VOLUME ${WORKSPACE}
VOLUME ${DATA}

RUN echo "USER =======> ${USER}"

RUN mkdir -p ${WORKSPACE} ${DATA} 

##################################
#### ---- VNC / noVNC ----    ####
##################################
ARG VNC_INSTALL_HOME=${HOME}
#ARG VNC_INSTALL_HOME=
### Envrionment config
ENV TERM=xterm \
    STARTUPDIR=${VNC_INSTALL_HOME}/dockerstartup \
    INST_SCRIPTS=${VNC_INSTALL_HOME}/install \
    NO_VNC_HOME=${VNC_INSTALL_HOME}/noVNC \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false

USER 0
WORKDIR ${HOME}

#### -----------------------------------
#### ---- Install CA certificates: ----
#### -----------------------------------
#ADD ./certificates $/certificates
#RUN ${SCRIPT_DIR}/setup_system_certificates.sh

#### -----------------------------------------------------------------
#### ---- VNC Resolution (1280x1024, 1600x1024, 1920x1280, etc.): ----
#### -----------------------------------------------------------------
ENV VNC_RESOLUTION=${VNC_RESOLUTION:-1280x1024}
#ENV VNC_RESOLUTION=${VNC_RESOLUTION:-1600x800}
#ENV VNC_RESOLUTION=${VNC_RESOLUTION:-1920x1080}

#### ----------------------
#### ---- VNC Password ----
#### ----------------------
ENV VNC_PW=${VNC_PW:-vncpassword}

### Add all install scripts for further steps
ADD ./src/common/install/ ${INST_SCRIPTS}/
ADD ./src/centos/install/ ${INST_SCRIPTS}/
RUN find ${INST_SCRIPTS} -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN ${INST_SCRIPTS}/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN ${INST_SCRIPTS}/tigervnc.sh
RUN ${INST_SCRIPTS}/no_vnc.sh

#### ==================================
#### ---- Install Google-Chrome:  =----
#### ==================================
### Install google-chrome or chrome browser
RUN ${INST_SCRIPTS}/chrome.sh
RUN ${INST_SCRIPTS}/google-chrome.sh

#### ------------------------------------------------
#### ---- Desktop setup (Google-Chrome, Firefox) ----
#### ------------------------------------------------
#ADD ./config/Desktop $HOME/

### Install WINDOW_MANAGER (xfce or icewm) UI
RUN ${INST_SCRIPTS}/${WINDOW_MANAGER}_ui.sh
ADD ./src/common/${WINDOW_MANAGER}/ ${HOME}/

### configure startup
RUN ${INST_SCRIPTS}/libnss_wrapper.sh
ADD ./src/common/scripts ${STARTUPDIR}
RUN ${INST_SCRIPTS}/set_user_permission.sh ${STARTUPDIR} ${HOME}

##################################
#### ---- VNC Startup ----    ####
##################################
WORKDIR ${HOME}
USER ${USER}

#### ==================================
#### ---- Install Firefox browser: ----
#### ==================================
#RUN ${INST_SCRIPTS}/firefox.sh
#RUN yum update -y firefox
#ENV FIREFOX_VERSION=${FIREFOX_VERSION:-79.0b9}
RUN ${INST_SCRIPTS}/firefox_latest.sh

#### ===============================================
#### ---- Change Owner to $USER:$USER for $HOME ----
#### ===============================================
ADD ./wrapper_process.sh $HOME/

RUN sudo chown -R ${USER}:${USER} ${HOME}

ENTRYPOINT ["/bin/bash", "-c", "${STARTUPDIR}/vnc_startup.sh"]
CMD ["--wait"]

## ---- Debug Use ----
#CMD ["/bin/bash"]
#CMD "$HOME/wrapper_process.sh"

# (or)
#COPY ./test/say_hello.sh $HOME/
#RUN sudo chmod +x $HOME/say_hello.sh
#CMD "$HOME/say_hello.sh"
