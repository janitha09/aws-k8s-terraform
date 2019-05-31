############################
############ K8S ###########
############################

# resource "null_resource" "kubernetes" {
#   triggers {
#     cluster_instance_ids = "${join(",", var.id)}"
#   }

#   count = "${var.count}"
#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = "${file("${path.module}/janitha.jayaweera.pem")}"
#     host        = "${element(var.public_ip, count.index)}"
#   }

  # provisioner "file" {
  #   source      = "${path.module}/templates/kubernetes.sh"
  #   destination = "/home/ubuntu/kubernetes.sh"
  # }

  # provisioner "file" {
  #   content     = "${data.template_file.10-kubeadm-conf.rendered}"
  #   destination = "/home/ubuntu/10-kubeadm.conf"
  # }

  # provisioner "file" {
  #   content     = "${element(data.template_file.kubeadm-config-yaml.*.rendered, count.index)}"
  #   destination = "/home/ubuntu/kubeadm.config.yaml"
  # }
# }


############################
######### Execute ##########
############################

resource "null_resource" "kubernetes_execute" {
  # depends_on = ["null_resource.kubernetes"]

  count = "${var.instances}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/janitha.jayaweera.pem")}" #${file("${path.module}/janitha.jayaweera.pem")}
    host        = "${element(var.public_ip, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get remove docker docker-engine docker.io containerd runc",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo bash -c 'cat > /etc/docker/daemon.json <<EOF",
              "{",
                "\"exec-opts\": [\"native.cgroupdriver=systemd\"],",
                "\"log-driver\": \"json-file\",",
                "\"log-opts\": {",
                  "\"max-size\": \"100m\"",
                "},",
                "\"storage-driver\": \"overlay2\"",
              "}",
      "EOF'",
      "cat /etc/docker/daemon.json",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart docker",
      "sudo docker info",
      "sudo usermod -aG docker $USER", #sudo groupadd docker
      "sudo apt-get update && apt-get install -y apt-transport-https curl",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "sudo bash -c 'cat > /etc/apt/sources.list.d/kubernetes.list <<EOF",
      "deb https://apt.kubernetes.io/ kubernetes-xenial main",
      "EOF'",
      "sudo cat /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update",
      "sudo apt-get install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl"
    ]
  }
}

# output "master_installed" {
#   value = true
# }
# ### MASTER ###

# resource "null_resource" "master" {
#   depends_on = ["null_resource.kubernetes_execute"]

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = "${var.private_key}"
#     host        = "${element(var.public_ip, 0)}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo kubeadm init --config kubeadm.config.yaml",
#       "sudo tar cvfz /tmp/cred.tar.gz /etc/kubernetes/pki/sa.* /etc/kubernetes/pki/ca.*"
#     ]
#   }

#   provisioner "local-exec" {
#     command = "scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i ${path.module}/certs/id_rsa ubuntu@${element(var.public_ip, 0)}:/tmp/cred.tar.gz /tmp/cred.tar.gz"
#   }
# }


# ### SLAVE ###

# resource "null_resource" "slave1" {
#   depends_on = ["null_resource.master"]

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = "${var.private_key}"
#     host        = "${element(var.public_ip, 1)}"
#   }

#   provisioner "file" {
#     source      = "/tmp/cred.tar.gz"
#     destination = "/home/ubuntu/cred.tar.gz"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo mv /home/ubuntu/cred.tar.gz /cred.tar.gz",
#       "pushd /",
#       "sudo tar xvfz cred.tar.gz",
#       "popd",
#       "sudo kubeadm init --config kubeadm.config.yaml"
#     ]
#   }
# }


# resource "null_resource" "slave2" {
#   depends_on = ["null_resource.master"]

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = "${var.private_key}"
#     host        = "${element(var.public_ip, 2)}"
#   }

#   provisioner "file" {
#     source      = "/tmp/cred.tar.gz"
#     destination = "/home/ubuntu/cred.tar.gz"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo mv /home/ubuntu/cred.tar.gz /cred.tar.gz",
#       "pushd /",
#       "sudo tar xvfz cred.tar.gz",
#       "popd",
#       "sudo kubeadm init --config kubeadm.config.yaml"
#     ]
#   }
# }

# ### Master ###

# resource "null_resource" "master-post" {
#   depends_on = ["null_resource.slave1", "null_resource.slave2"]

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = "${var.private_key}"
#     host        = "${element(var.public_ip, 0)}"
#   }

#   provisioner "file" {
#     source      = "${path.module}/templates/flannel.yml"
#     destination = "/home/ubuntu/flannel.yml"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "mkdir -p $HOME/.kube",
#       "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
#       "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
#       "kubectl apply -f flannel.yml"
#     ]
#   }
# }

