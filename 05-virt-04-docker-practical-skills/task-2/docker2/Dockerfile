FROM ubuntu:latest
RUN apt-get update \
    && apt-get install -y wget \
    && apt-get install -y gnupg2 \
    && apt-get install -y openjdk-11-jdk
RUN wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
RUN sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get update && apt-get install -y jenkins
EXPOSE 8080
EXPOSE 50000