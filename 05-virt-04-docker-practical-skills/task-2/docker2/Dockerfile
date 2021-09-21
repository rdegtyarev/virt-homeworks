FROM ubuntu:latest

RUN apt-get update && apt-get install -y wget gnupg2 openjdk-11-jdk && rm -rf /var/lib/apt/lists/*

ARG http_port=8080
ARG agent_port=50000

RUN wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - \
    && sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' \
    && apt-get update && apt-get install -y jenkins

EXPOSE ${http_port}

EXPOSE ${agent_port}

ENTRYPOINT service jenkins start && bash