# This Dockerfile is used to build an headles vnc image based on Ubuntu

FROM openkbs/jdk-mvn-py3

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

ARG DISPLAY=${DISPLAY:-":1"}
ENV DISPLAY=${DISPLAY:-":1"}

ARG USER_ID=${USER_ID:-1000}
ENV USER_ID=${USER_ID:-1000}

ARG GROUP_ID=${GROUP_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}

#### ----------------------------------------------------------------------
#### ---- Code from https://github.com/ConSol/docker-headless-vnc-container
#### ----------------------------------------------------------------------

#### ---- Window Manager: xfce or icewm ----
ENV WINDOW_MANAGER=${WINDOW_MANAGER:-xfce}

LABEL io.k8s.description="Headless VNC Container with ${WINDOW_MANAGER} window manager, firefox and chromium" \
      io.k8s.display-name="Headless VNC Container based on Ubuntu" \
      io.openshift.expose-services="6901:http,5901:xvnc" \
      io.openshift.tags="vnc, ubuntu, ${WINDOW_MANAGER}" \
      io.openshift.non-scalable=true

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://<IP>:6901/?password=vncpassword

ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
ENV HOME=/home/developer 
RUN mkdir -p ${HOME}

ENV \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=${HOME}/install \
    NO_VNC_HOME=${HOME}/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

#### ---- VNC Resolution (1280x1024, 1920x1280, etc.): ----
#ENV VNC_RESOLUTION=${VNC_RESOLUTION:-1920x1280}
ENV VNC_RESOLUTION=${VNC_RESOLUTION:-1280x1024}

#### ---- VNC Password ----
ENV VNC_PW=${VNC_PW:-vncpassword}

### Add all install scripts for further steps
ADD ./src/common/install/ ${INST_SCRIPTS}/
ADD ./src/ubuntu/install/ ${INST_SCRIPTS}/
RUN find ${INST_SCRIPTS} -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN ${INST_SCRIPTS}/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install custom fonts
RUN ${INST_SCRIPTS}/install_custom_fonts.sh

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN ${INST_SCRIPTS}/tigervnc.sh
RUN ${INST_SCRIPTS}/no_vnc.sh

### Install firefox and chrome browser
RUN ${INST_SCRIPTS}/firefox.sh
RUN ${INST_SCRIPTS}/chrome.sh

### Install WINDOW_MANAGER (xfce or icewm) UI
RUN ${INST_SCRIPTS}/${WINDOW_MANAGER}_ui.sh
ADD ./src/common/${WINDOW_MANAGER}/ $HOME/

### configure startup
RUN ${INST_SCRIPTS}/libnss_wrapper.sh
ADD ./src/common/scripts ${STARTUPDIR}
RUN ${INST_SCRIPTS}/set_user_permission.sh ${STARTUPDIR} $HOME

#### -------------------------
#### ---- user: developer ----
#### -------------------------
ENV USER=${USER:-developer}
ENV USER_NAME=${USER}

ENV HOME=/home/${USER}

RUN useradd ${USER} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p ${HOME} && \
    mkdir -p ${HOME}/workspace && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER}:x:${USER_ID}:${GROUP_ID}:${USER},,,:${HOME}:/bin/bash" >> /etc/passwd && \
    echo "${USER}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    chown ${USER}:${USER} -R ${HOME} && \
    apt-get clean all 

RUN apt-get install -y sudo

WORKDIR ${HOME}

USER ${USER}

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]

CMD ["--wait"]
