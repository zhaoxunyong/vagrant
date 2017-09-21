#!/bin/sh
#http://www.360doc.com/content/14/1125/19/7044580_428024359.shtml
echo "scripting......"

filepath=/vagrant

sed -i 's;en_GB;zh_CN;' /etc/sysconfig/i18n

yum -y install yum-fastestmirror

if [ ! -f "/etc/yum.repos.d/CentOS-Base.repo.from.aliyun.backup" ]; then 
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.from.aliyun.backup
	#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS6-Base-163.repo
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
	yum clean all
	yum makecache
fi 

#wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
rpm -ivh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

#yum install gcc gcc-c++ make bind-untils libevent libevent-devel sysstat autoconf \
# curl curl-devel -y
#yum install gcc gcc-c++ kernel-devel make autoconf libevent libevent-devel bind-untils

yum -y install ntpdate net-tools setuptool iptables system-config-securitylevel-tui system-config-network-tui \
 ntsysv net-tools lrzsz telnet lsof dos2unix unix2dos zip unzip vim curl curl-devel
 
##升级内核为3.10
#rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
##cd /etc/yum.repos.d/
#rpm -ivh http://www.elrepo.org/elrepo-release-6-6.el6.elrepo.noarch.rpm
#yum --enablerepo=elrepo-kernel install kernel-lt kernel-lt-devel -y
##修改grub.conf文件的default=0
#sed -i 's;^default=.*;default=0;' /etc/grub.conf
#sed -i 's;^default=.*;default=0;' /boot/grub/grub.conf 
#
#/opt/VBoxGuestAdditions-4.3.30/init/vboxadd setup
##reboot uname -r

#chkconfig --level 35 memcached on
#service iptables stop
#chkconfig --level 35 iptables on

sed -i 's;SELINUX=.*;SELINUX=disabled;' /etc/selinux/config
setenforce 0
getenforce

ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime

cat /etc/security/limits.conf|grep 65535 > /dev/null
if [[ $? != 0 ]]; then
cat >> /etc/security/limits.conf  << EOF
*               soft    nofile             65535
*               hard    nofile             65535
*               soft    nproc              65535
*               hard    nproc              65535
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
EOF
	sysctl -p
fi

#mkdir /usr/local/java > /dev/null 2>&1 
#cd $filepath/files
#tar zxf jdk-8u91-linux-x64.tar.gz -C /usr/local/java/
#ln -sf /usr/local/java/jdk1.8.0_91 /usr/local/java/jdk
#
#cat /etc/profile|grep "JAVA_HOME" > /dev/null
#if [[ $? != 0 ]]; then
#cat >> /etc/profile  << EOF
#export JAVA_HOME=/usr/local/java/jdk
#export PATH=\$JAVA_HOME/bin:\$PATH
#EOF
#	source /etc/profile
#fi
#
#yum -y install libevent libevent-devel zlib zlib-devel pcre pcre-devel openssl openssl-devel

