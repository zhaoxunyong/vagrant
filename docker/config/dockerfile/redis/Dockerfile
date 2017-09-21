# Version: 1.0.0
FROM docker.io/centos
MAINTAINER zhaoxunyong@qq.com

RUN yum -y install epel-release
RUN yum -y install redis

VOLUME [ "/var/lib/redis", "/var/log/redis" ]

#ENTRYPOINT [ "redis-server", "--logfile", "/var/log/redis/redis-server.log" ]
ENTRYPOINT [ "redis-server" ]

EXPOSE 6379
