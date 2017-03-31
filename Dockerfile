FROM debian:jessie
MAINTAINER brettm357@me.com
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
RUN apt-get -t jessie-backports install openjdk-8-jre-headless

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
