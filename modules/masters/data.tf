############################
########### DATA ###########
############################

data "template_file" "etcd-conf" {
  template = "${file("${path.module}/templates/etcd.conf")}"
  count = "${var.aws_instance["count"]}"

  vars {
    ETCD_NAME="master${count.index}"
    ETCD_LISTEN_PEER_URLS="http://${element(aws_instance.cluster.*.private_ip, count.index)}:2380"
    ETCD_LISTEN_CLIENT_URLS="http://${element(aws_instance.cluster.*.private_ip, count.index)}:2379,http://127.0.0.1:2379"
    ETCD_ADVERTISE_CLIENT_URLS="http://${element(aws_instance.cluster.*.private_ip, count.index)}:2379"
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${element(aws_instance.cluster.*.private_ip, count.index)}:2380"
    ETCD_INITIAL_CLUSTER="master0=http://${aws_instance.cluster.0.private_ip}:2380,master1=http://${aws_instance.cluster.1.private_ip}:2380,master2=http://${aws_instance.cluster.2.private_ip}:2380"
  }
}

#data "aws_eip" "proxy_ip" {
#  public_ip = "${var.eip}"
#}

