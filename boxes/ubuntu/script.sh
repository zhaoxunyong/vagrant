#!/bin/sh
#http://www.360doc.com/content/14/1125/19/7044580_428024359.shtml
#http://blog.csdn.net/54powerman/article/details/50684844
#http://c.biancheng.net/cpp/view/2739.html
echo "scripting......"

filepath=/vagrant

sudo locale-gen zh_CN.UTF-8
sudo cp /etc/default/locale /etc/default/locale_bak
sudo sed -i 's,en_US,zh_CN.UTF-8,g' /etc/default/locale

sudo timedatectl set-timezone Asia/Shanghai

sudo sed -i 's;^PermitRootLogin.*;PermitRootLogin yes;g' /etc/ssh/sshd_config
sudo systemctl restart ssh

#logined limit
#http://willam2004.iteye.com/blog/1199687
cat /proc/sys/fs/file-max
cat >> /etc/security/limits.conf  << EOF
*               -    nofile             100000
*               -    nproc              100000
root            -    nofile             100000
root            -    nproc              100000

EOF

#cat >> /etc/pam.d/common-session  << EOF
#session required       pam_limits.so
#EOF
#
#cat >> /etc/profile  << EOF
#ulimit -SHn 100000
#EOF

#http://engrzhou.github.io/2016/01/Shasowsocks-Ubuntu%E5%86%85%E6%A0%B8%E4%BC%98%E5%8C%96/
#http://hongtoushizi.iteye.com/blog/2236314
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 500
net.ipv4.ip_forward = 1
EOF

sysctl -p

#systemd limit
cat >> /etc/systemd/system.conf << EOF
DefaultLimitCORE=infinity
DefaultLimitNOFILE=100000
DefaultLimitNPROC=100000
EOF

tee /etc/resolv.conf << EOF
search zhaoxy.com
nameserver 114.114.114.114
nameserver 8.8.8.8
EOF

cat >> /etc/apt/sources.list.d/aliyun.list << EOF
deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
EOF

sudo apt-get update

#install docker start
sh docker.sh
#install docker end
