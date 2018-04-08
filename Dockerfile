# Pull base image
FROM jlesage/baseimage-gui:ubuntu-16.04

# Recommends are as of now still abused in many packages
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/no-recommends
RUN echo "APT::Get::Assume-Yes "true";" > /etc/apt/apt.conf.d/always-yes

# Add gambas launchpad to our repo
RUN echo "deb http://ppa.launchpad.net/gambas-team/gambas3/ubuntu xenial main" >> /etc/apt/sources.list
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 50B027516CAEE58D

# Update and upgrade our repo information
RUN apt-get -qq update && apt-get upgrade

# Set language correctly
RUN apt-get install locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Gambas, ip and rrdtool required for DomotiGa
RUN apt-get install gambas3 \
                    iproute2 \
                    rrdtool

# Install MySQL Server, it is optional
RUN echo 'mysql-server mysql-server/root_password password domotiga' | debconf-set-selections
RUN echo 'mysql-server mysql-server/root_password_again password domotiga' | debconf-set-selections
RUN apt-get install mysql-server

# Git is required by DomotiGa and OpenZWave
RUN apt-get install git-core

# Download DomotiGa software from git
RUN GIT_SSL_NO_VERIFY=true git clone -b beta --single-branch https://github.com/DomotiGa/DomotiGa.git /domotiga

# Cleanup git of DomotiGa
RUN rm -rf /domotiga/.git

# Set work directory
WORKDIR /domotiga

# OpenZWave build dependencies, most will be removed after compilation
RUN apt-get install build-essential \
                    libudev-dev \ 
                    libjson0 \
                    libjson0-dev \
                    libcurl4-gnutls-dev

# Download OpenZWave software from git
RUN GIT_SSL_NO_VERIFY=true git clone https://github.com/OpenZWave/open-zwave /domotiga/wrappers/domozwave/open-zwave

# Cleanup git of OpenZWave
RUN rm -rf /domotiga/wrappers/domozwave/open-zwave/.git

# Build OpenZWave library
RUN cd /domotiga/wrappers/domozwave/open-zwave && make

# Build domozwave library
RUN cd /domotiga/wrappers/domozwave && make && make install
RUN rm -f /domotiga/wrappers/domozwave/libdomozwave.so

# Remove open-zwave directory, but keep the configs
RUN mv /domotiga/wrappers/domozwave/open-zwave /domotiga/wrappers/domozwave/open-zwave.bak && \
    mkdir /domotiga/wrappers/domozwave/open-zwave && \
    cp -rp /domotiga/wrappers/domozwave/open-zwave.bak/config /domotiga/wrappers/domozwave/open-zwave && \
    rm -rf /domotiga/wrappers/domozwave/open-zwave.bak

# Copy the start script
COPY rootfs/ /

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
    apt-get clean

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose XML-RPC, JSON-RPC and broadcasts for client/server
EXPOSE 9009/tcp 9090/tcp 19009/udp

# Expose DomotiGa dirs
VOLUME ["/domotiga/config", "/domotiga/logs", "/domotiga/rrd"]

# Expose the local MySQL
VOLUME ["/var/lib/mysql"]

# allow mapping host usb devices
#VOLUME ["/dev/bus/usb"]
#VOLUME ["/dev/serial"]

