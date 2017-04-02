FROM debian:jessie
MAINTAINER brettm357@me.com

# Build Docker image to run the UniFi controller
#
FROM debian:jessie
MAINTAINER The Goofball goofball222@gmail.com

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV UNIFI_VERSION 5.4.11

# Add apt repository keys, non-default sources, update apt database to load new data
# Install deps and mongodb, download unifi .deb, install and remove package
# Cleanup after apt to minimize image size
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
  echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" \
    | tee -a /etc/apt/sources.list.d/mongodb.list && \
  echo "deb http://ftp.debian.org/debian jessie-backports main" \
    | tee -a /etc/apt/sources.list.d/jessie-backports.list && \
  apt-get update -q && \
  apt-get --no-install-recommends -y install \
    supervisor \
    binutils \
    wget && \
  apt-get -t jessie-backports --no-install-recommends -y install \
    openjdk-8-jre-headless && \
  apt-get --no-install-recommends -y install \
    jsvc \
    mongodb-server && \
  wget -nv https://www.ubnt.com/downloads/unifi/$UNIFI_VERSION/unifi_sysvinit_all.deb && \
  dpkg --install unifi_sysvinit_all.deb && \
  rm unifi_sysvinit_all.deb && \
  apt-get -y autoremove wget && \
  apt-get -q clean && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /tmp/* /var/tmp/* 

# Forward apporpriate ports
EXPOSE 3478/udp 6789/tcp 8080/tcp 8443/tcp 8843/tcp 8880/tcp 10001/udp

# Set internal storage volume
VOLUME ["/usr/lib/unifi/data", "/usr/lib/unifi/logs"]

# Set working directory for program
WORKDIR /usr/lib/unifi

#  Add supervisor config
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Configure user nobody to match unRAID's settings
 RUN \
 usermod -u 99 nobody && \
 usermod -g 100 nobody && \
 usermod -d /home nobody && \
 chown -R nobody:users /home


#Update APT-GET list
RUN \
  apt-get update -q && \
  apt-get upgrade -y && \
  apt-get dist-upgrade -y

# Install Common Dependencies
#RUN apt-get -y install curl software-properties-common

# Install Oracle Java 8
#RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
#RUN add-apt-repository ppa:webupd8team/java && apt-get update
#RUN apt-get -y install oracle-java8-installer
#RUN update-java-alternatives -s java-8-oracle
#ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
#ENV JAVA8_HOME /usr/lib/jvm/java-8-oracle

RUN echo "deb http://http.debian.net/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN apt-get update
RUN apt-get -t install jessie-backports openjdk-8-jre-headless

# MongoDB
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
ADD mongodb.list /etc/apt/sources.list.d/mongodb.list
RUN apt-get update && apt-get -y install mongodb-server

# UniFi
RUN apt-get -y install jsvc
RUN curl -L -o unifi_sysvinit_all.deb http://www.ubnt.com/downloads/unifi/5.5.7-0cbda0cd4a/unifi_sysvinit_all.deb
RUN dpkg --install unifi_sysvinit_all.deb

# fix execstack warning on library
RUN apt-get install -y \
	execstack
RUN execstack -c \
	/usr/lib/unifi/lib/native/Linux/amd64/libubnt_webrtc_jni.so

# Wipe out auto-generated data
RUN rm -rf /var/lib/unifi/*

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8081 8443 8843 8880

ADD run.sh /run.sh
RUN chmod 755 /run.sh

CMD ["/run.sh"]
