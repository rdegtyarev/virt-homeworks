FROM centos:7

ARG http_port=9200
ARG transport_port=9300

RUN yum -y update && yum install -y wget perl-Digest-SHA

RUN groupadd elastic && \
useradd elastic -g elastic

WORKDIR /opt

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.1-linux-x86_64.tar.gz \
&& wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.1-linux-x86_64.tar.gz.sha512 \
&& shasum -a 512 -c elasticsearch-7.15.1-linux-x86_64.tar.gz.sha512 \
&& tar -xzf elasticsearch-7.15.1-linux-x86_64.tar.gz

EXPOSE ${http_port}
EXPOSE ${transport_port}

WORKDIR /opt/elasticsearch-7.15.1
COPY ./config/elasticsearch.yml ./config/
COPY ./config/jvm.options ./config/
RUN mkdir snapshots
RUN chown -R elastic:elastic /opt/elasticsearch-7.15.1 /var/lib

USER elastic

CMD ["./bin/elasticsearch"]