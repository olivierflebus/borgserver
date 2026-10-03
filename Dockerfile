############################################################
# Dockerfile to build borgbackup server images
# Based on Debian
############################################################
# same functionality as b3vis/docker-borgmatic
# but with another base image

FROM python:3.14.8-slim-trixie

# from official borgbackup from source
# but assuming python is already installed

# we need tzdata to use the TZ variable
RUN apt-get update && apt upgrade -y && \
    apt-get install --no-install-recommends -y \
    curl \
    rsyslog \
    logrotate \
    openssh-client \
    openssl \
    libssl-dev \
    libacl1-dev \
    liblz4-dev \
    libzstd-dev \
    libxxhash-dev \
    build-essential \
    libfuse3-dev fuse3 pkg-config python3-pkgconfig \
    tzdata \   
    && apt-get clean \
    && rm -rf /var/lib/apt/lists

RUN pip3 install -U pip setuptools wheel
RUN pip3 install pkgconfig
RUN pip3 install borgbackup[pyfuse3]


RUN apt-get update && apt-get -y --no-install-recommends install \
		openssh-server && apt-get clean && \
		useradd -s /bin/bash -m -U borg && \
		mkdir /home/borg/.ssh && \
		chmod 700 /home/borg/.ssh && \
		chown borg:borg /home/borg/.ssh && \
		mkdir -p /run/sshd && \
		rm -f /etc/ssh/ssh_host*key* && \
		rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Volume for SSH-Keys
VOLUME /sshkeys

# Volume for borg repositories
VOLUME /backup

COPY ./data/run.sh /run.sh
COPY ./data/sshd_config /etc/ssh/sshd_config

ENTRYPOINT ["bash", "/run.sh"]

# Default SSH-Port for clients
EXPOSE 22
