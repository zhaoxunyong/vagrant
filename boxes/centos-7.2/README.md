sudo vagrant box add centos-7.2 vagrant-centos-7.2.box 
sudo vagrant init centos-7.2
sudo vagrant up
sudo vagrant halt
vagrant box list

vagrant init  # 初始化
vagrant up  # 启动虚拟机
vagrant halt  # 关闭虚拟机
vagrant reload  # 重启虚拟机
vagrant ssh  # SSH 至虚拟机
vagrant status  # 查看虚拟机运行状态
vagrant destroy  # 销毁当前虚拟机

https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1.msi
http://download.virtualbox.org/virtualbox/5.0.20/VirtualBox-5.0.20-106931-Win.exe
http://www.ttlsa.com/linux/use-vagrant-cross-platform/
http://blog.star7th.com/2015/06/1538.html
http://www.vagrantbox.es/

see: http://www.phperz.com/article/15/0314/56026.html
http://www.phperz.com/article/15/1210/173574.html
http://www.phperz.com/article/15/0314/56027.html
http://www.continuousdelivery.info/index.php/2011/10/27/vagrant_jenkins_vm/
https://segmentfault.com/a/1190000002645737
http://blog.csdn.net/54powerman/article/details/50684844
http://www.php1.cn/article/9870.html
http://www.oschina.net/translate/unsuck-your-vagrant-developing-in-one-vm-with-vagrant-and-docker

http://www.cnblogs.com/suihui/p/4362233.html
http://www.jianshu.com/p/a101846e8df1

http://www.jeroenreijn.com/2014/11/using_vagrant_with_puppet.html
http://www.erikaheidi.com/blog/a-beginners-guide-to-vagrant-and-puppet-part-3-facts-conditional

http://garylarizza.com/blog/2013/02/01/repeatable-puppet-development-with-vagrant/
https://jtreminio.com/2013/05/introduction_to_vagrant_puppet_and_introducing_puphpet_a_simple_to_use_vagrant_puppet_gui_configurator/

tomcat session:
http://www.iyunv.com/thread-42365-1-1.html
https://github.com/magro/memcached-session-manager/wiki/SetupAndConfiguration

mkdir d:\HashiCorp\boxes\centos-6.7
cd d:\HashiCorp\boxes\centos-6.7
vagrant box add centos-6.7 vagrant-centos-6.7.box
vagrant init centos-6.7
vagrant box list
vagrant up
vagrant halt
vagrant ssh
#重新启动script.sh脚本
vagrant reload --provision
启动时自动执行，缺省地，任务只执行一次，第二次启动就不会自动运行了。如果需要每次都自动运行，需要为provision指定run:"always"属性
启动时运行，在启动命令加 --provision 参数,适用于 vagrant up 和 vagrant reload
vm启动状态时，执行 vagrant provision 命令。


注意：destroy会清空虚拟机中的所有数据，不清空数据需要用halt
vagrant destory

导出（退出并关闭虚拟机vagrant halt）：
vagrant package --output zxy-centos-6.7.box


通过SecureCRT连接127.0.0.1:2222 
登录：root/vagrant
修改：vim /etc/sysconfig/i18n
LANG="zh_CN.UTF-8"
SYSFONT="latarcyrheb-sun16"
修改时区：
http://www.cnblogs.com/dingyingsi/archive/2013/02/26/2933239.html
ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime

yum -y install yum-fastestmirror
NetworkManager 
yum install memcached ntpdate setuptool iptables system-config-securitylevel-tui system-config-network-tui ntsysv net-tools lrzsz telnet lsof dos2unix unix2dos zip unzip vim sysstat -y

groupadd -g 2016 web
useradd web -u 2016 -g 2016
mkdir -p /temp/tempFile
chown -R web:web /temp/tempFile

修改主机名称：
vim /etc/sysconfig/network
HOSTNAME=www.dev.com
执行：
hostname www.dev.com


vim /etc/sysconfig/selinux
SELINUX=disabled
SELINUXTYPE=targeted
执行：
setenforce 0
getenforce

vim /etc/security/limits.conf
*               soft    nofile             65535
*               hard    nofile             65535
*               soft    nproc              65535
*               hard    nproc              65535


vim /etc/sysctl.conf
http://itindex.net/detail/51140-centos7-web-%E6%9C%8D%E5%8A%A1%E5%99%A8
http://binyan17.iteye.com/blog/2177679

net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65535

sysctl -p

cat /proc/sys/net/ipv4/ip_local_port_range

cat /etc/security/limits.d/90-nproc.conf

mkdir /usr/local/java
tar zxvf jdk-8u77-linux-x64.tar.gz -C /usr/local/java/
ln -s /usr/local/java/jdk1.8.0_77 /usr/local/java/jdk
cat >> /etc/profile  << EFF
export JAVA_HOME=/usr/local/java/jdk
export PATH=\$JAVA_HOME/bin:\$PATH
EFF
source /etc/profile

unzip apache-tomcat-8.0.35.zip
mv apache-tomcat-8.0.35 /usr/local/
ln -s /usr/local/apache-tomcat-8.0.35 /usr/local/tomcat
chmod +x /usr/local/tomcat/bin/*.sh

cd /usr/local/tomcat/bin
tar zxvf commons-daemon-native.tar.gz
cd commons-daemon-1.0.15-native-src/unix/
./configure
make
cp jsvc /usr/local/tomcat/bin
useradd tomcat -M -d / -s /usr/sbin/nologin
chown -R tomcat.tomcat /usr/local/tomcat
chmod a+x /usr/local/tomcat/bin/daemon.sh
修改/usr/local/tomcat/bin/daemon.sh ：
在文件靠前位置的注释中加入下面的内容
# chkconfig: - 80 20

if [ -f /etc/profile ]; then
   . /etc/profile
fi

ln -s /usr/local/tomcat/bin/daemon.sh /etc/init.d/tomcat
chkconfig --add tomcat
chkconfig --level 35 tomcat on

tomcat非root启动：
http://www.cnblogs.com/allegro/p/5005352.html
http://www.bubuko.com/infodetail-538924.html


./configure --prefix=/usr/local/nginx --user=www --group=www --pid-path=/var/run/nginx.pid --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre=/opt/software/pcre-8.10 --with-zlib=/opt/software/zlib-1.2.5 --with-http_stub_status_module --with-http_realip_module --with-http_gzip_static_module --with-http_ssl_module
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module
./configure --user=www --group=www --prefix=/usr/local/nginx-1.4.7 --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module \
    --with-http_mp4_module  --add-module=${CUR_DIR}/src/nginx-accesskey-2.0.3 \
    --add-module=${CUR_DIR}/src/nginx-rtmp-module --add-module=${CUR_DIR}/src/nginx_mod_h264_streaming-2.2.7

	
yum install gcc gcc-c++ make libevent libevent-devel sysstat vim wget libxml2 libxml2-devel autoconf \
libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel zlib zlib-devel glibc glibc-devel \
 glib2 glib2-devel openssl openssl-devel perl perl-devel php-common php-gd libtool-ltdl-devel curl \
 curl-devel libc-client-devel  libicu-devel  readline-devel pcre pcre-devel ntpdate net-tools bind-utils
 
-----------------------------------------------------------------------------------------------------------------------
mkdir /var/log/nginx 
groupadd -f www
useradd -s /sbin/nologin -g www www 
chown -R www.www /var/log/nginx /usr/local/nginx
 
yum -y install libevent libevent-devel zlib zlib-devel pcre pcre-devel openssl openssl-devel
./configure --prefix=/usr/local/nginx --user=www --group=www --pid-path=/var/run/nginx.pid --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-http_stub_status_module --with-http_realip_module --with-http_gzip_static_module --with-http_ssl_module

