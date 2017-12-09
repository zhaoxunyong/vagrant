#!/bin/sh
#https://docs.docker.com/engine/installation/linux/ubuntu/

shadowsocks_host=192.168.10.1
shadowsocks_port=1080

docker_install_folder=/docker/k8s.deb

sudo apt-get install -y --no-install-recommends \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual

sudo apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

## curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -
## sudo add-apt-repository \
##        "deb https://apt.dockerproject.org/repo/ \
##        ubuntu-$(lsb_release -cs) \
##        main"

#curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository \
#    "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable"

#curl -fsSL http://mirrors.aliyun.com/docker-engine/apt/gpg | sudo apt-key add -
#sudo add-apt-repository \
#    "deb [arch=amd64] http://mirrors.aliyun.com/docker-engine/apt/repo \
#    ubuntu-xenial \
#    main"

#http://blog.csdn.net/CSDN_duomaomao/article/details/77683607
#https://www.xtplayer.cn/2017/02/2783
curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -
cat >/etc/apt/sources.list.d/docker-main.list<<EOF
deb [arch=amd64] http://mirrors.aliyun.com/docker-engine/apt/repo ubuntu-xenial main
EOF
# apt-get update && apt-get upgrade -y 
sudo apt-get update

#apt-cache policy docker-engine
# sudo apt-get -y install docker-engine
#sudo apt-get -y install docker-engine=1.12.6-0~ubuntu-xenial

#apt-get download docker-engine=1.12.6-0~ubuntu-xenial
cd $docker_install_folder
gdebi docker-engine_1.12.6-0~ubuntu-xenial_amd64.deb
systemctl enable docker


sed -i "s;^ExecStart=/usr/bin/dockerd.*;ExecStart=/usr/bin/dockerd -H fd:// \
--registry-mirror=http://3fecfd09.m.daocloud.io \
--registry-mirror=https://3gbbfq7n.mirror.aliyuncs.com \
--registry-mirror=http://zhaoxunyong.m.alauda.cn;" \
/lib/systemd/system/docker.service

mkdir -p /etc/systemd/system/docker.service.d
cat >> /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=http://${shadowsocks_host}:${shadowsocks_port}"
Environment="HTTPS_PROXY=http://${shadowsocks_host}:${shadowsocks_port}"
Environment="NO_PROXY=localhost,${shadowsocks_host},192.168.10.6,192.168.10.7,192.168.10.8"
EOF

systemctl daemon-reload
systemctl show --property=Environment docker

systemctl restart docker

#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
#deb http://apt.kubernetes.io/ kubernetes-xenial main
#EOF
#apt-get update
#apt-get install -y kubeadm=1.7.5-00 kubelet=1.7.5-00 kubectl=1.7.5-00 kubernetes-cni=0.5.1-00

#apt-get download kubernetes-cni-0.5.1-0.x86_64 kubelet-1.7.5-0.x86_64 kubectl-1.7.5-0.x86_64 kubeadm-1.7.5-0.x86_64
cd $docker_install_folder
#install:dpkg -i安装时不会自动下载依赖包，需要自动下载依赖包时，需要安装gdebi
gdebi kubernetes-cni_0.5.1-00_amd64.deb
gdebi kubelet_1.7.5-00_amd64.deb
gdebi kubectl_1.7.5-00_amd64.deb
gdebi kubeadm_1.7.5-00_amd64.deb
systemctl enable kubelet

sed -i 's;systemd;cgroupfs;g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

tee >> ~/.bash_profile << EOF
function proxy_off(){
    unset http_proxy
    unset https_proxy
    echo -e "已关闭代理"
}

function proxy_on() {
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,${shadowsocks_host},192.168.10.6,192.168.10.7,192.168.10.8"
    export http_proxy="http://${shadowsocks_host}:${shadowsocks_port}"
    export https_proxy="http://${shadowsocks_host}:${shadowsocks_port}"
    echo -e "已开启代理"
}
EOF

. ~/.bash_profile
