cat /etc/sysctl.conf|grep "net.ipv4.ip_forward" > /dev/null
if [[ $? != 0 ]]; then
cat >> /etc/sysctl.conf  << EOF
net.ipv4.ip_forward = 1
EOF
sysctl -p
fi