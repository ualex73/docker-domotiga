# Pull base image
FROM jlesage/baseimage-gui:ubuntu-16.04

LABEL maintainer="Alex <ualex73@gmail.com>"

# Version information
ARG VERSION="1.0.025"
ARG BUILDDATE="20180808"

# Recommends are as of now still abused in many packages
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/no-recommends && \
    echo "APT::Get::Assume-Yes "true";" > /etc/apt/apt.conf.d/always-yes

# Add gambas launchpad to our repo
RUN echo "deb http://ppa.launchpad.net/gambas-team/gambas3/ubuntu xenial main" >> /etc/apt/sources.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 50B027516CAEE58D

# Update and upgrade our repo information
RUN apt-get -qq update && apt-get upgrade

# Set language correctly
RUN apt-get install locales && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Gambas, ip, rrdtool, git-core and Open-Zwave requirements for DomotiGa
RUN apt-get install gambas3 \
    iproute2 \
    rrdtool \
    git-core \
    mysql-client \
    build-essential \
    libudev-dev \                
    libjson0 \
    libjson0-dev \
    libcurl4-gnutls-dev

# Download DomotiGa software from git, also remove git data after copy
RUN GIT_SSL_NO_VERIFY=true git clone --single-branch https://github.com/DomotiGa/DomotiGa.git /domotiga && \
    rm -rf /domotiga/.git

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
    cp -rp /domotiga/wrappers/domozwave/open-zwave.bak/config /domotiga/wrappers/domozwave/open-zwave && \
    rm -rf /domotiga/wrappers/domozwave/open-zwave.bak

# Copy the start script
COPY rootfs/ /

# Set work directory
WORKDIR /domotiga

# Set the name of the application
ENV APP_NAME="DomotiGa"

# Add dialout (20) to app user 
ENV SUP_GROUP_IDS=20

# Clean up
RUN apt-get purge git-core \
    git \
    git-man \
    build-essential \
    cpp \
    cpp-5 \
    g++ \
    g++-5 \
    gcc \
    gcc-5 \
    libasan2 \
    libatomic1 \
    libc-dev-bin \
    libc6-dev \
    libcc1-0 \
    libcilkrts5 \
    libgcc-5-dev \
    libisl15 \
    libitm1 \
    libmpc3 \
    libmpfr4 \
    libmpx0 \
    libquadmath0 \
    libstdc++-5-dev \
    libubsan0 \
    linux-libc-dev && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose JSON-RPC and broadcasts for client/server
EXPOSE 9090/tcp 19009/udp

# Expose DomotiGa dirs
VOLUME ["/domotiga/config", "/domotiga/logs", "/domotiga/rrd"]

# allow mapping host usb devices
#VOLUME ["/dev/bus/usb"]
#VOLUME ["/dev/serial"]

