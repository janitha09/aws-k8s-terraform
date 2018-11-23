############################
############ K8S ###########
############################

resource "null_resource" "kubernetes" {
  triggers {
    cluster_instance_ids = "${join(",", var.id)}"
  }

  count = "${var.count}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${var.private_key}"
    host        = "${element(var.public_ip, count.index)}"
  }

  provisioner "file" {
    source      = "${path.module}/templates/kubernetes.sh"
    destination = "/home/ubuntu/kubernetes.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.10-kubeadm-conf.rendered}"
    destination = "/home/ubuntu/10-kubeadm.conf"
  }

  provisioner "file" {
    content     = "${element(data.template_file.kubeadm-config-yaml.*.rendered, count.index)}"
    destination = "/home/ubuntu/kubeadm.config.yaml"
  }
}


############################
######### Execute ##########
############################

resource "null_resource" "kubernetes_execute" {
  depends_on = ["null_resource.kubernetes"]

  count = "${var.count}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${var.private_key}"
    host        = "${element(var.public_ip, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash kubernetes.sh"
    ]
  }
}


### MASTER ###

resource "null_resource" "master" {
  depends_on = ["null_resource.kubernetes_execute"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${var.private_key}"
    host        = "${element(var.public_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubeadm init --config kubeadm.config.yaml",
      "sudo tar cvfz /tmp/cred.tar.gz /etc/kubernetes/pki/sa.* /etc/kubernetes/pki/ca.*"
    ]
  }

  provisioner "local-exec" {
    command = "scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i ${path.module}/certs/id_rsa ubuntu@${element(var.public_ip, 0)}:/tmp/cred.tar.gz /tmp/cred.tar.gz"
  }
}


### SLAVE ###

resource "null_resource" "slave1" {
  depends_on = ["null_resource.master"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${var.private_key}"
    host        = "${element(var.public_ip, 1)}"
  }

  provisioner "file" {
    source      = "/tmp/cred.tar.gz"
    destination = "/home/ubuntu/cred.tar.gz"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ubuntu/cred.tar.gz /cred.tar.gz",
      "pushd /",
      "sudo tar xvfz cred.tar.gz",
      "popd",
      "sudo kubeadm init --config kubeadm.config.yaml"
    ]
  }
}


resource "null_resource" "slave2" {
  depends_on = ["null_resource.master"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${var.private_key}"
    host        = "${element(var.public_ip, 2)}"
  }

  provisioner "file" {
    source      = "/tmp/cred.tar.gz"
    destination = "/home/ubuntu/cred.tar.gz"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ubuntu/cred.tar.gz /cred.tar.gz",
      "pushd /",
      "sudo tar xvfz cred.tar.gz",
      "popd",
      "sudo kubeadm init --config kubeadm.config.yaml"
    ]
  }
}

### Master ###

resource "null_resource" "master-post" {
  depends_on = ["null_resource.slave1", "null_resource.slave2"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${var.private_key}"
    host        = "${element(var.public_ip, 0)}"
  }

  provisioner "file" {
    source      = "${path.module}/templates/flannel.yml"
    destination = "/home/ubuntu/flannel.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "kubectl apply -f flannel.yml"
    ]
  }
}

