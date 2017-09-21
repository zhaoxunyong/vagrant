#!/bin/sh
#http://www.360doc.com/content/14/1125/19/7044580_428024359.shtml
echo "scripting......"

filepath=/vagrant

cd $filepath/files

unzip -o apache-tomcat-8.0.35.zip > /dev/null
mv apache-tomcat-8.0.35 /usr/local/
ln -sf /usr/local/apache-tomcat-8.0.35 /usr/local/tomcat
chmod +x /usr/local/tomcat/bin/*.sh

cd /usr/local/tomcat/bin
tar zxf commons-daemon-native.tar.gz
cd commons-daemon-1.0.15-native-src/unix/
./configure
make
/bin/cp -a jsvc /usr/local/tomcat/bin
useradd tomcat -M -d / -s /usr/sbin/nologin > /dev/null 2>&1
chown -R tomcat.tomcat /usr/local/tomcat
chown -R tomcat.tomcat /usr/local/apache-tomcat-8.0.35
chmod a+x /usr/local/tomcat/bin/daemon.sh

cd $filepath/conf
/bin/cp -a ROOT.xml /usr/local/tomcat/conf/Catalina/localhost/
/bin/cp -a tomcat-users.xml /usr/local/tomcat/conf/
/bin/cp -a test.jsp /usr/local/tomcat/webapps/ROOT/
cd $filepath/libs
/bin/cp -a *.jar /usr/local/tomcat/lib/

cat /usr/local/tomcat/bin/daemon.sh|grep chkconfig > /dev/null
if [[ $? != 0 ]]; then
	str="# chkconfig: - 80 20\n\n"
	str+="if [ -f /etc/profile ]; then\n\n"
	str+="   . /etc/profile\n\n"
	str+="fi\n"
	sed -i "1a$str" /usr/local/tomcat/bin/daemon.sh
	
	ln -s /usr/local/tomcat/bin/daemon.sh /etc/init.d/tomcat
	chkconfig --add tomcat
	chkconfig --level 35 tomcat on
	/etc/init.d/tomcat stop
	/etc/init.d/tomcat start
fi

cd $filepath/files
mkdir /var/log/nginx /usr/local/nginx > /dev/null 2>&1
groupadd -f www > /dev/null 2>&1
useradd -s /sbin/nologin -g www www > /dev/null 2>&1 
chown -R www.www /var/log/nginx /usr/local/nginx

yum -y install libevent libevent-devel zlib zlib-devel pcre pcre-devel openssl openssl-devel
tar zxf nginx-1.11.1.tar.gz
cd nginx-1.11.1
./configure --prefix=/usr/local/nginx --user=www --group=www \
  --pid-path=/var/run/nginx.pid --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
  --with-http_stub_status_module --with-http_realip_module --with-http_gzip_static_module --with-http_ssl_module
make
make install

cd $filepath/conf
/bin/cp -a nginx.conf /usr/local/nginx/conf/
/bin/cp -a nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
chkconfig --add nginx
chkconfig --level 35 nginx on
/etc/init.d/nginx stop
/etc/init.d/nginx start


cd $filepath/files
rm -fr apache-tomcat-8.0.35
rm -fr nginx-1.11.1

