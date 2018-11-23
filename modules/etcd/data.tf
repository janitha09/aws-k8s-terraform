############################
########### DATA ###########
############################

data "template_file" "etcd-conf" {
  template = "${file("${path.module}/templates/etcd.conf")}"
  count = "${var.count}"

  vars {
    ETCD_NAME="master${count.index}"
    ETCD_LISTEN_PEER_URLS="http://${element(var.private_ip, count.index)}:2380"
    ETCD_LISTEN_CLIENT_URLS="http://${element(var.private_ip, count.index)}:2379,http://127.0.0.1:2379"
    ETCD_ADVERTISE_CLIENT_URLS="http://${element(var.private_ip, count.index)}:2379"
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${element(var.private_ip, count.index)}:2380"
    ETCD_INITIAL_CLUSTER="master0=http://${element(var.private_ip, 0)}:2380,master1=http://${element(var.private_ip, 1)}:2380,master2=http://${element(var.private_ip, 2)}:2380"
  }
}

