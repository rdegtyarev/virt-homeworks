FROM amazoncorretto

ARG http_port=8080
ARG agent_port=50000

RUN yum -y update && yum install -y wget
RUN wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo \
    && rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key \
    && amazon-linux-extras install -y epel java-openjdk11 \
    && yum install -y jenkins

EXPOSE ${http_port}
EXPOSE ${agent_port}

CMD [ "java", "-jar",  "/usr/lib/jenkins/jenkins.war"]