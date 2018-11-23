#!/bin/bash
apt update
apt install -y apt-transport-https \
               ca-certificates \
               software-properties-common \
               curl

# docker apt repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# kubernetes apt repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

# update apt repository & installation
apt update
apt install -y docker-ce=18.06.1~ce~3-0~ubuntu kubeadm=1.9.7-00 kubectl=1.9.7-00 kubelet=1.9.7-00 kubernetes-cni=0.6.0-00

# setting
swapoff -a

echo "br_netfilter" >> /etc/modules
modprobe br_netfilter

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
sysctl -p

cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=cgroupfs"],
  "iptables": false
}
EOF
systemctl restart docker

mv 10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload

