#!/bin/sh

mkdir /usr/local/java > /dev/null 2>&1 
tar zxf jdk-8u111-linux-x64.tar.gz -C /usr/local/java/
ln -sf /usr/local/java/jdk1.8.0_111 /usr/local/java/jdk

cat /etc/profile|grep "JAVA_HOME" > /dev/null
if [[ $? != 0 ]]; then
cat >> /etc/profile  << EOF
export JAVA_HOME=/usr/local/java/jdk
export PATH=\$JAVA_HOME/bin:\$PATH
EOF
source /etc/profile
fi

