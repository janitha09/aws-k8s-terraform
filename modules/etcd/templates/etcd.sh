#!/bin/bash
sudo curl -sSL https://github.com/coreos/etcd/releases/download/v3.1.10/etcd-v3.1.10-linux-amd64.tar.gz | sudo tar -xz --strip-components=1 -C /usr/local/bin/
sudo rm -rf etcd-v3.1.10-linux-amd64* | true

sudo mkdir -p /var/lib/etcd
sudo groupadd -f -g 1501 etcd
sudo useradd -c "Etcd key-value store user" -d /var/lib/etcd -s /bin/false -g etcd -u 1501 etcd
sudo chown -R etcd:etcd /var/lib/etcd

sudo mkdir -p /etc/etcd
sudo mv ~/etcd.conf /etc/etcd/etcd.conf
sudo mv ~/etcd.service /etc/systemd/system/etcd.service
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
etcdctl member list

