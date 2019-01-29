##################################
## ---- user: developer ----
##################################
#ARG USER_ID=${USER_ID:-1000}
#ENV USER_ID=${USER_ID}

ARG GROUP_ID=${GROUP_ID:-1000}
ENV GROUP_ID=${GROUP_ID}

ENV USER_NAME=${1:-developer}
ENV HOME=/home/${USER_NAME}

RUN useradd ${USER_NAME} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p ${HOME} && \
    mkdir -p ${PRODUCT_WORKSPACE} && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:${USER_NAME},,,:${HOME}:/bin/bash" >> /etc/passwd && \
    echo "${USER_NAME}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME} && \
    chmod 0440 /etc/sudoers.d/${USER_NAME} && \
    chown ${USER_NAME}:${USER_NAME} -R ${HOME} && \
    apt-get clean all && \
    ls /usr/local/ 
    
RUN chown -R ${USER_NAME}:${USER_NAME}  ${PRODUCT_WORKSPACE} ${PRODUCT_PROFILE} 

