#!/bin/sh
#http://www.360doc.com/content/14/1125/19/7044580_428024359.shtml
#http://blog.csdn.net/54powerman/article/details/50684844
#http://c.biancheng.net/cpp/view/2739.html
echo "scripting......"

filepath=/vagrant
bip=$1
hostname=$2

if [[ "$hostname" != "" ]]; then
	hostnamectl --static set-hostname $hostname
	sysctl kernel.hostname=$hostname
fi

#sed -i 's;SELINUX=.*;SELINUX=disabled;' /etc/selinux/config
sed -i 's/enforcing/disabled/g' /etc/selinux/config
setenforce 0
getenforce

cat /etc/NetworkManager/NetworkManager.conf|grep "dns=none" > /dev/null
if [[ $? != 0 ]]; then
	echo "dns=none" >> /etc/NetworkManager/NetworkManager.conf
	systemctl restart NetworkManager.service
fi

systemctl disable iptables
systemctl stop iptables
systemctl disable firewalld
systemctl stop firewalld

ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime

cat /etc/security/limits.conf|grep 65535 > /dev/null
if [[ $? != 0 ]]; then
cat >> /etc/security/limits.conf  << EOF
#*               soft    nofile             65535
#*               hard    nofile             65535
#*               soft    nproc              65535
#*               hard    nproc              65535
*               -    nofile             65535
*               -    nproc              65535
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
EOF
sysctl -p
fi

su - root -c "ulimit -a"

#echo '192.168.10.6 k8s-master
#192.168.10.7   k8s-node1
#192.168.10.8   k8s-node2' >> /etc/hosts

##sed -i 's;en_GB;zh_CN;' /etc/sysconfig/i18n

#yum -y install gcc kernel-devel
mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

tee /etc/yum.repos.d/docker.repo <<-'EOF'
[docker]
name=Docker Repository
baseurl=http://mirrors.aliyun.com/docker-engine/yum/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/docker-engine/yum/gpg
EOF
#
#tee /etc/yum.repos.d/k8s.repo <<-'EOF'
#[k8s-repo]
#name=kubernetes Repository
##baseurl=https://rpm.mritd.me/centos/7/x86_64
##baseurl=file:///docker/works/yum
#baseurl=http://www.gcalls.cn/yum
#enabled=1
#gpgcheck=1
##gpgkey=https://cdn.mritd.me/keys/rpm.public.key
##gpgkey=file:///docker/works/yum/gpg
#gpgkey=http://www.gcalls.cn/yum/gpg
#EOF

yum clean all
yum makecache

#yum -y install epel-release
#yum -y install createrepo rpm-sign rng-tools yum-utils 
yum -y install bind-utils bridge-utils ntpdate setuptool iptables system-config-securitylevel-tui system-config-network-tui \
 ntsysv net-tools lrzsz telnet lsof vim dos2unix unix2dos zip unzip

#install docker-engine start-----------------------------------------------
#yum -y install docker-engine python2-pip
#pip install -U docker-compose

rpm -e docker-1.10.3-59.el7.centos.x86_64 \
 docker-common-1.10.3-59.el7.centos.x86_64 \
 container-selinux-1.10.3-59.el7.centos.x86_64 > /dev/null 2>&1

yum install docker-engine -y
##yum install -y etcd kubernetes
##sed -i "s;^ExecStart=/usr/bin/dockerd$;ExecStart=/usr/bin/dockerd --registry-mirror=https://3gbbfq7n.mirror.aliyuncs.com;" /usr/lib/systemd/system/docker.service
#
#sed -i "s;^ExecStart=/usr/bin/dockerd$;ExecStart=/usr/bin/dockerd ${bip} \
sed -i "s;^ExecStart=/usr/bin/dockerd$;ExecStart=/usr/bin/dockerd \
--registry-mirror=http://3fecfd09.m.daocloud.io \
--registry-mirror=https://3gbbfq7n.mirror.aliyuncs.com \
--registry-mirror=http://zhaoxunyong.m.alauda.cn;" \
/usr/lib/systemd/system/docker.service

#mkdir -p /etc/systemd/system/docker.service.d
#cat >> /etc/systemd/system/docker.service.d/http-proxy.conf  << EOF
#[Service]
#Environment="HTTP_PROXY=http://thenorth.f.ftq.me:52579"
#Environment="HTTPS_PROXY=http://thenorth.f.ftq.me:52579"
#Environment="NO_PROXY=localhost,127.0.0.1,docker.io"
#EOF
#
#systemctl daemon-reload
#systemctl show --property=Environment docker

systemctl restart docker
systemctl enable docker

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
#fi#
