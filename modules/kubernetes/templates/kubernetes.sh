# apt-get remove docker docker-engine docker.io containerd runc || true
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# add-apt-repository \
#            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#               $(lsb_release -cs) \
#                  stable"
# apt-get update
# apt-get install -y docker-ce docker-ce-cli containerd.io
# cat > /etc/docker/daemon.json <<EOF
#         {
#           "exec-opts": ["native.cgroupdriver=systemd"],
#           "log-driver": "json-file",
#           "log-opts": {
#             "max-size": "100m"
#           },
#           "storage-driver": "overlay2"
#         }
# EOF
# cat /etc/docker/daemon.json
# systemctl daemon-reload
# systemctl restart docker
# docker info
# apt-get update && apt-get install -y apt-transport-https curl
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# cat > /etc/apt/sources.list.d/kubernetes.list <<EOF
# deb https://apt.kubernetes.io/ kubernetes-xenial main
# EOF
# cat /etc/apt/sources.list.d/kubernetes.list
# apt-get update
# apt-get install -y kubelet kubeadm kubectl
# apt-mark hold kubelet kubeadm kubectl