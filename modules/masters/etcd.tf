############################
########### ETCD ###########
############################

resource "null_resource" "etcd" {
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.cluster.*.id)}"
  }

  count = "${var.aws_instance["count"]}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.module}/${var.key["private_key"]}")}"
    host        = "${element(aws_instance.cluster.*.public_ip, count.index)}"
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

  count = "${var.aws_instance["count"]}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.module}/${var.key["private_key"]}")}"
    host        = "${element(aws_instance.cluster.*.public_ip, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname master${count.index}",
      "bash etcd.sh"
    ]
  }
}

