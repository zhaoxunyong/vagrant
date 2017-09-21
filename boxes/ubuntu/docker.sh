#!/bin/sh
#https://docs.docker.com/engine/installation/linux/ubuntu/
sudo apt-get install -y --no-install-recommends \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual

sudo apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -

sudo add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       ubuntu-$(lsb_release -cs) \
       main"

sudo apt-get update

sudo apt-get -y install docker-engine

sed -i "s;^ExecStart=/usr/bin/dockerd.*;ExecStart=/usr/bin/dockerd -H fd:// \
--registry-mirror=http://3fecfd09.m.daocloud.io \
--registry-mirror=https://3gbbfq7n.mirror.aliyuncs.com \
--registry-mirror=http://zhaoxunyong.m.alauda.cn;" \
/lib/systemd/system/docker.service

mkdir -p /etc/systemd/system/docker.service.d
cat >> /etc/systemd/system/docker.service.d/http-proxy.conf  << EOF
[Service]
Environment="HTTP_PROXY=http://thenorth.f.ftq.me:52579"
Environment="HTTPS_PROXY=http://thenorth.f.ftq.me:52579"
Environment="NO_PROXY=localhost,127.0.0.1,docker.io"
EOF

systemctl daemon-reload
systemctl show --property=Environment docker

systemctl restart docker
systemctl enable docker
