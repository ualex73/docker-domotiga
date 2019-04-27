# Pull base image
FROM jlesage/baseimage-gui:ubuntu-18.04

LABEL maintainer="Alex <ualex73@gmail.com>"

# Version information
ARG VERSION="1.0.026"
ARG BUILDDATE="20190427"

# Recommends are as of now still abused in many packages
# Update/Upgrade packages. Install gnupg for PPA and install locals
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/no-recommends && \
    echo "APT::Get::Assume-Yes "true";" > /etc/apt/apt.conf.d/always-yes && \
    apt-get -qq update && \
    apt-get install gnupg \
            locales && \
    locale-gen en_US.UTF-8 && \
    echo "deb http://ppa.launchpad.net/gambas-team/gambas3/ubuntu bionic main" >> /etc/apt/sources.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 50B027516CAEE58D && \
    apt-get -qq update

# Set language correctly
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Gambas, ip, rrdtool, git-core and Open-Zwave requirements for DomotiGa
RUN apt-get install gambas3 \
    iproute2 \
    iputils-ping \
    arp-scan \
    rrdtool \
    git-core \
    mysql-client \
    build-essential \
    libudev-dev \                
    libcurl4-gnutls-dev

# Download DomotiGa software from git, also remove git data after copy
RUN GIT_SSL_NO_VERIFY=true git clone --single-branch https://github.com/DomotiGa/DomotiGa.git /domotiga && \
    rm -rf /domotiga/.git && \
    chown -R 1000:1000 /domotiga

# Download OpenZWave software from git and build it
RUN GIT_SSL_NO_VERIFY=true git clone https://github.com/OpenZWave/open-zwave /domotiga/wrappers/domozwave/open-zwave && \
    rm -rf /domotiga/wrappers/domozwave/open-zwave/.git && \
    cd /domotiga/wrappers/domozwave/open-zwave && \
    make && \
    cd /domotiga/wrappers/domozwave && \
    make && \
    make install && \
    rm -f /domotiga/wrappers/domozwave/libdomozwave.so && \
    mv /domotiga/wrappers/domozwave/open-zwave /domotiga/wrappers/domozwave/open-zwave.bak && \
    mkdir /domotiga/wrappers/domozwave/open-zwave && \
    mv /domotiga/wrappers/domozwave/open-zwave.bak/config /domotiga/wrappers/domozwave/open-zwave && \
    rm -rf /domotiga/wrappers/domozwave/open-zwave.bak

# Copy the start script
COPY rootfs/ /

# Set work directory
WORKDIR /domotiga

# Set the name of the application
ENV APP_NAME="DomotiGa"

# Add dialout (20) to app user 
ENV SUP_GROUP_IDS=20

# Restart DomotiGa if something happens
ENV KEEP_APP_RUNNING=1

# Clean up
RUN apt-get purge git \
    git-man \
    git-core && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose JSON-RPC and broadcasts for client/server
EXPOSE 9090/tcp 19009/udp

# Expose DomotiGa dirs
VOLUME ["/domotiga/config", "/domotiga/logs", "/domotiga/rrd"]

