############################
########### ETCD ###########
############################

resource "null_resource" "etcd" {
#  triggers {
#    cluster_instance_ids = "${join(",", aws_instance.cluster.*.id)}"
#  }

  count = "${var.count}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${var.private_key}"
    host        = "${element(var.public_ip, count.index)}"
  }

  provisioner "file" {
    source      = "${path.module}/templates/etcd.sh"
    destination = "/home/ubuntu/etcd.sh"
  }

  provisioner "file" {
    content     = "${element(data.template_file.etcd-conf.*.rendered, count.index)}"
    destination = "/home/ubuntu/etcd.conf"
  }

  provisioner "file" {
    source      = "${path.module}/templates/etcd.service"
    destination = "/home/ubuntu/etcd.service"
  }
}


############################
######### Execute ##########
############################

resource "null_resource" "etcd_execute" {
  depends_on = ["null_resource.etcd"]

  count = "${var.count}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${var.private_key}"
    host        = "${element(var.public_ip, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname master${count.index}",
      "bash etcd.sh"
    ]
  }
}

