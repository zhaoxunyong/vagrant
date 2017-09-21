#!/bin/sh
#http://www.360doc.com/content/14/1125/19/7044580_428024359.shtml
#http://blog.csdn.net/54powerman/article/details/50684844
#http://c.biancheng.net/cpp/view/2739.html
echo "scripting......"

CDH_PATH=/vagrant/CDH-5.10.0
#bip=$1
#hostname=$2

#if [[ "$hostname" != "" ]]; then
#	hostnamectl --static set-hostname $hostname
#	sysctl kernel.hostname=$hostname
#fi

sed -i 's;SELINUX=.*;SELINUX=disabled;' /etc/selinux/config
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

#ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai

#logined limit
cat /etc/security/limits.conf|grep 100000 > /dev/null
if [[ $? != 0 ]]; then
cat >> /etc/security/limits.conf  << EOF
*               soft    nofile             100000
*               hard    nofile             100000
*               soft    nproc              100000
*               hard    nproc              100000
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
vm.swappiness = 10
EOF
sysctl -p
fi

su - root -c "ulimit -a"

cat >> /etc/rc.local << EOF
echo never > /sys/kernel/mm/transparent_hugepage/defrag
EOF

echo '192.168.10.6 namenode.zhaoxy.com managernode.zhaoxy.com namenode managernode
192.168.10.7 datanode1.zhaoxy.com datanode1
192.168.10.8 datanode2.zhaoxy.com datanode2' >> /etc/hosts

tee /etc/resolv.conf << EOF
search zhaoxy.com
nameserver 114.114.114.114
nameserver 8.8.8.8
EOF


##sed -i 's;en_GB;zh_CN;' /etc/sysconfig/i18n

#yum -y install gcc kernel-devel
mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#yum -y install epel-release

yum clean all
yum makecache

#yum -y install createrepo rpm-sign rng-tools yum-utils 
yum -y install bind-utils bridge-utils ntpdate setuptool iptables system-config-securitylevel-tui system-config-network-tui \
 ntsysv net-tools lrzsz telnet lsof vim dos2unix unix2dos zip unzip

rpm -e docker-1.10.3-59.el7.centos.x86_64 \
 docker-common-1.10.3-59.el7.centos.x86_64 \
 container-selinux-1.10.3-59.el7.centos.x86_64 > /dev/null 2>&1

mkdir -p /usr/local/java /usr/java > /dev/null 2>&1 
cd $CDH_PATH
tar zxf jdk-8u112-linux-x64.tar.gz -C /usr/local/java/
#ln -sf /usr/local/java/jdk1.8.0_112 /usr/local/java/jdk
ln -sf /usr/local/java/jdk1.8.0_112 /usr/java/jdk1.8

cat /etc/profile|grep "JAVA_HOME" > /dev/null
if [[ $? != 0 ]]; then
cat >> /etc/profile  << EOF
export JAVA_HOME=/usr/java/jdk1.8
export PATH=\$JAVA_HOME/bin:\$PATH
EOF
chown -R root.root /usr/local/java/jdk1.8.0_112/
source /etc/profile
fi
