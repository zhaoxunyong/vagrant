tee >> /etc/systemd/system/docker.service.d/http-proxy.conf  << EOF
[Service]
Environment="HTTP_PROXY=http://192.168.107.107:1080"
Environment="HTTPS_PROXY=http://192.168.107.107:1080"
Environment="NO_PROXY=localhost,192.168.107.107,docker.io"
EOF

tee >> ~/.bash_profile << EOF
function proxy_off(){
    unset http_proxy
    unset https_proxy
    echo -e "已关闭代理"
}

function proxy_on() {
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
    export http_proxy="http://192.168.107.107:1080"
    export https_proxy=$http_proxy
    echo -e "已开启代理"
}
EOF

. ~/.bash_profile

cat >>/etc/sysctl.conf<< EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

cat >> /etc/yum.repos.d/docker.repo <<EOF
[docker-repo]
name=Docker Repository
baseurl=http://mirrors.aliyun.com/docker-engine/yum/repo/main/centos/7
enabled=1
gpgcheck=0
EOF

cat >> /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF


docker pull gcr.io/google_containers/kube-proxy-amd64:v1.6.2
docker pull gcr.io/google_containers/kube-apiserver-amd64:v1.6.2
docker pull gcr.io/google_containers/kube-controller-manager-amd64:v1.6.2
docker pull gcr.io/google_containers/kube-scheduler-amd64:v1.6.2
docker pull gcr.io/google_containers/etcd-amd64:3.0.17
docker pull gcr.io/google_containers/kube-discovery-amd64:1.0
docker pull gcr.io/google_containers/kubedns-amd64:1.7
docker pull gcr.io/google_containers/exechealthz-amd64:1.1
docker pull gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.1
docker pull gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.1
docker pull gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.1
docker pull gcr.io/google_containers/pause-amd64:3.0