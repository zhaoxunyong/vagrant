#!/bin/sh
#http://www.360doc.com/content/14/1125/19/7044580_428024359.shtml
#http://blog.csdn.net/54powerman/article/details/50684844
#http://c.biancheng.net/cpp/view/2739.html
echo "scripting......"

filepath=/vagrant
hostname=$1
ip=$2
shadowsocks_ip=192.168.11.1
shadowsocks_domain=docker.zxy.com
shadowsocks_port=1080

tee /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="static"
ONBOOT="yes"
TYPE="Ethernet"
IPADDR="${ip}"
NETMASK="255.255.255.0"
GATEWAY="192.168.11.1"
DNS1="114.114.114.114"
DNS2="8.8.8.8"
EOF

systemctl restart network

sed -i 's;^PasswordAuthentication.*;PasswordAuthentication yes;' /etc/ssh/sshd_config
systemctl restart sshd

yum -y install wget

if [[ "$hostname" != "" ]]; then
	hostnamectl --static set-hostname $hostname
	sysctl kernel.hostname=$hostname
fi

sed -i 's;SELINUX=.*;SELINUX=disabled;' /etc/selinux/config
setenforce 0
getenforce

sed -i 's;^PasswordAuthentication.*;PasswordAuthentication yes;' /etc/ssh/sshd_config
systemctl restart sshd

#LANG="en_US.UTF-8"
sed -i 's;LANG=.*;LANG="zh_CN.UTF-8";' /etc/locale.conf

cat /etc/NetworkManager/NetworkManager.conf|grep "dns=none" > /dev/null
if [[ $? != 0 ]]; then
	echo "dns=none" >> /etc/NetworkManager/NetworkManager.conf
	systemctl restart NetworkManager.service
fi

systemctl disable iptables
systemctl stop iptables
systemctl disable firewalld
systemctl stop firewalld

#ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai

#logined limit
cat /etc/security/limits.conf|grep 100000 > /dev/null
if [[ $? != 0 ]]; then
cat >> /etc/security/limits.conf  << EOF
*               -    nofile             100000
*               -    nproc              100000
EOF
fi

sed -i 's;4096;100000;g' /etc/security/limits.d/20-nproc.conf

#systemd service limit
cat /etc/systemd/system.conf|egrep '^DefaultLimitCORE' > /dev/null
if [[ $? != 0 ]]; then
cat >> /etc/systemd/system.conf << EOF
DefaultLimitCORE=infinity
DefaultLimitNOFILE=100000
DefaultLimitNPROC=100000
EOF
fi

cat /etc/sysctl.conf|grep "net.ipv4.ip_local_port_range" > /dev/null
if [[ $? != 0 ]]; then
cat >> /etc/sysctl.conf  << EOF
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.ip_forward = 1
#k8s
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p
fi

su - root -c "ulimit -a"

echo "${shadowsocks_ip} ${shadowsocks_domain}
192.168.10.6   k8s-master
192.168.10.7   k8s-node1
192.168.10.8   k8s-node2" >> /etc/hosts

tee /etc/resolv.conf << EOF
search myk8s.com
nameserver 114.114.114.114
nameserver 8.8.8.8
EOF

#yum -y install gcc kernel-devel
mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

tee /etc/yum.repos.d/docker.repo <<-'EOF'
[docker-repo]
name=Docker Repository
#baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/
baseurl=https://mirrors.aliyun.com/docker-engine/yum/repo/main/centos/7/
enabled=1
gpgcheck=1
#gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
gpgkey=https://mirrors.aliyun.com/docker-engine/yum/gpg
EOF

#https://kubernetes.io/docs/getting-started-guides/centos/centos_manual_config/
tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes-repo]
name=Kubernetes Repository
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF

#yum -y install epel-release

yum clean all
yum makecache

#yum -y install createrepo rpm-sign rng-tools yum-utils 
yum -y install bind-utils bridge-utils ntpdate setuptool iptables system-config-securitylevel-tui system-config-network-tui \
 ntsysv net-tools lrzsz telnet lsof vim dos2unix unix2dos zip unzip

#install docker-compose-----------------------------------------------

rpm -e docker-1.10.3-59.el7.centos.x86_64 \
 docker-common-1.10.3-59.el7.centos.x86_64 \
 container-selinux-1.10.3-59.el7.centos.x86_64 > /dev/null 2>&1

#yum install docker-ce -y
yum install -y docker-engine-1.12.6-1.el7.centos.x86_64
systemctl enable docker

#yum -y install python2-pip
#pip install -U docker-compose

yum install -y kubernetes-cni-0.5.1-0.x86_64 kubelet-1.7.5-0.x86_64 kubectl-1.7.5-0.x86_64 kubeadm-1.7.5-0.x86_64
systemctl enable kubelet

#sed -i "s;^ExecStart=/usr/bin/dockerd$;ExecStart=/usr/bin/dockerd ${bip} \
sed -i "s;^ExecStart=/usr/bin/dockerd$;ExecStart=/usr/bin/dockerd \
--registry-mirror=http://3fecfd09.m.daocloud.io \
--registry-mirror=https://3gbbfq7n.mirror.aliyuncs.com \
--registry-mirror=http://zhaoxunyong.m.alauda.cn;" \
/usr/lib/systemd/system/docker.service

mkdir -p /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/http-proxy.conf  << EOF
[Service]
Environment="HTTP_PROXY=http://${shadowsocks_domain}:${shadowsocks_port}"
Environment="HTTPS_PROXY=http://${shadowsocks_domain}:${shadowsocks_port}"
Environment="NO_PROXY=localhost,${shadowsocks_domain},docker.io"
EOF

systemctl daemon-reload
#systemctl show --property=Environment docker

systemctl restart docker

tee >> ~/.bash_profile << EOF
function proxy_off(){
    unset http_proxy
    unset https_proxy
    echo -e "已关闭代理"
}

function proxy_on() {
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
    export http_proxy="http://${shadowsocks_domain}:${shadowsocks_port}"
    export https_proxy=$http_proxy
    echo -e "已开启代理"
}
EOF

. ~/.bash_profile

#cd /docker/works/images/k8s/
#./importK8s.sh
#
#docker load -i /docker/works/images/others/redis-master.tar 
#docker load -i /docker/works/images/others/guestbook-redis-slave.tar 
#docker load -i /docker/works/images/others/guestbook-php-frontend.tar
#
#docker load -i /docker/works/images/k8s/tar/quagga.tar
#docker run -itd --name=router --privileged --net=host index.alauda.cn/georce/router
#docker start `docker ps -a |grep 'index.alauda.cn/georce/router'|awk '{print $1}'`

#install docker-engine end-----------------------------------------------

#mkdir /usr/local/java > /dev/null 2>&1 
#cd $filepath/files
#tar zxf jdk-8u111-linux-x64.tar.gz -C /usr/local/java/
#ln -sf /usr/local/java/jdk1.8.0_111 /usr/local/java/jdk
#
#cat /etc/profile|grep "JAVA_HOME" > /dev/null
#if [[ $? != 0 ]]; then
#cat >> /etc/profile  << EOF
#	export JAVA_HOME=/usr/local/java/jdk
#	export PATH=\$JAVA_HOME/bin:\$PATH
#EOF
#	source /etc/profile
#fi