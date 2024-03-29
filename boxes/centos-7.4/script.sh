#!/bin/sh
#http://www.360doc.com/content/14/1125/19/7044580_428024359.shtml
#http://blog.csdn.net/54powerman/article/details/50684844
#http://c.biancheng.net/cpp/view/2739.html
echo "scripting......"

hostname=$1

shadowsocks_host=192.168.10.1
shadowsocks_port=1080

#base------------------------------------------------------------------------------------------
#yum -y install wget

if [[ "$hostname" != "" ]]; then
    hostnamectl --static set-hostname $hostname
    sysctl kernel.hostname=$hostname
fi

sed -i 's;SELINUX=.*;SELINUX=disabled;' /etc/selinux/config
setenforce 0
getenforce

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

echo "192.168.10.6   k8s-master
192.168.10.7   k8s-node1
192.168.10.8   k8s-node2" >> /etc/hosts

tee /etc/resolv.conf << EOF
search myk8s.com
nameserver 114.114.114.114
nameserver 8.8.8.8
EOF

#yum -y install gcc kernel-devel
mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo

yum -y install epel-release

sudo mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
sudo mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup

cat > /etc/yum.repos.d/epel.repo  << EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/7/\$basearch
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 7 - \$basearch - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/7/\$basearch/debug
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-7&arch=\$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 7 - \$basearch - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/7/SRPMS
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-source-7&arch=\$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1
EOF

yum clean all
yum makecache

#yum -y install createrepo rpm-sign rng-tools yum-utils 
yum -y install htop bind-utils bridge-utils ntpdate setuptool iptables system-config-securitylevel-tui system-config-network-tui \
 ntsysv net-tools lrzsz telnet lsof vim dos2unix unix2dos zip unzip \
 openssl openssh-server openssh-clients

systemctl enable sshd
#base------------------------------------------------------------------------------------------


#docker------------------------------------------------------------------------------------------
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

rpm -e docker-1.10.3-59.el7.centos.x86_64 \
 docker-common-1.10.3-59.el7.centos.x86_64 \
 container-selinux-1.10.3-59.el7.centos.x86_64 > /dev/null 2>&1

#yum install docker-ce -y
yum install -y docker-engine-1.12.6-1.el7.centos.x86_64 docker-engine-selinux-1.12.6-1.el7.centos.noarch

systemctl enable docker

yum -y install python2-pip
pip install -U docker-compose



#sed -i "s;^ExecStart=/usr/bin/dockerd$;ExecStart=/usr/bin/dockerd ${bip} \
sed -i "s;^ExecStart=/usr/bin/dockerd$;ExecStart=/usr/bin/dockerd \
--registry-mirror=https://3gbbfq7n.mirror.aliyuncs.com \
--registry-mirror=https://registry.docker-cn.com \
--registry-mirror=http://hub-mirror.c.163.com \
--registry-mirror=http://3fecfd09.m.daocloud.io \
--registry-mirror=http://zhaoxunyong.m.alauda.cn;" \
/usr/lib/systemd/system/docker.service

mkdir -p /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/http-proxy.conf  << EOF
[Service]
Environment="HTTP_PROXY=http://${shadowsocks_host}:${shadowsocks_port}"
Environment="HTTPS_PROXY=http://${shadowsocks_host}:${shadowsocks_port}"
Environment="NO_PROXY=localhost,${shadowsocks_host},192.168.10.6,192.168.10.7,192.168.10.8"
EOF

systemctl daemon-reload
#systemctl show --property=Environment docker

#/usr/lib/systemd/system/docker.service
## DOCKER_RAMDISK disables pivot_root in Docker, using MS_MOVE instead.
#Environment=DOCKER_RAMDISK=yes
#Environment=HTTP_PROXY=http://192.168.10.1:1080
#Environment=HTTPS_PROXY=http://192.168.10.1:1080

systemctl restart docker

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
#10.0.0.0/8 192.168.0.0/16 172.16.0.0/12
. ~/.bash_profile
#docker------------------------------------------------------------------------------------------


#k8s------------------------------------------------------------------------------------------
#https://kubernetes.io/docs/getting-started-guides/centos/centos_manual_config/
tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes-repo]
name=Kubernetes Repository
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF

# yum install -y kubernetes-cni-0.5.1-0.x86_64 kubelet-1.6.2-0.x86_64 kubectl-1.6.2-0.x86_64 kubeadm-1.6.2-0.x86_64
yum install -y kubernetes-cni-0.5.1-0.x86_64 kubelet-1.7.5-0.x86_64 kubectl-1.7.5-0.x86_64 kubeadm-1.7.5-0.x86_64
#yum install -y etcd-3.1.9-2.el7.x86_64 flannel-0.7.1-2.el7.x86_64

sed -i 's;systemd;cgroupfs;g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl enable kubelet
#k8s------------------------------------------------------------------------------------------
