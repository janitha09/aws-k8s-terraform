variable "k8s_master_private_ips" {
  type = list
  default = [
    "10.63.129.106",
    "10.63.131.51",
    "10.63.135.157"
  ]
}

variable "k8s_node_private_ips" {
  type = list
  default = [
    "10.63.131.189",
    "10.63.129.128",
    "10.63.134.109"
  ]
}
variable "aws_public_key" {
  type = string
}

variable "k8s_installed_on_first_master" {
  type = string
}

resource "null_resource" "dummyvar" {
  provisioner "local-exec" {
    command = "echo ${var.k8s_installed_on_first_master}"
  }
}
resource "null_resource" "prep_docker_container" {
  depends_on = ["null_resource.dummyvar"]
  provisioner "local-exec" {
    # private_key = "${file("${path.root}/${var.aws_public_key}")}" #${file("${path.module}/${var.aws_public_key}")}

    command = "apk add bash && apk add jq && mkdir -p /pemfile && cp ${path.root}/${var.aws_public_key}.pem /pemfile && chmod 400 /pemfile/${var.aws_public_key}.pem"
  }
}
data "external" "kubeadm_join_node" {
  depends_on = ["null_resource.prep_docker_container"]
  program    = ["${path.module}/scripts/kubeadm-token.sh"]

  query = {
    host = var.k8s_master_private_ips.0
    key  = "/pemfile/${var.aws_public_key}.pem"
  }

  # depends_on = ["scaleway_server.k8s_master"]
}

output "kubeadm_join_command" {
  value = "${data.external.kubeadm_join_node.result["command"]}"
}

data "external" "kubeadm_join_secret" {
  depends_on = ["null_resource.prep_docker_container"]
  program    = ["${path.module}/scripts/kubeadm-secret.sh"]

  query = {
    host = var.k8s_master_private_ips.0
    key  = "/pemfile/${var.aws_public_key}.pem"
  }
}

output "kubeadm_join_secret" {
  value = "${data.external.kubeadm_join_secret.result["command"]}"
}


resource "null_resource" "install_join_masters" {
  count = length(var.k8s_master_private_ips)
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}" #${file("${path.module}/${var.aws_public_key}")}
    host        = "${element(var.k8s_master_private_ips, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo ${data.external.kubeadm_join_node.result["command"]} --experimental-control-plane --certificate-key ${data.external.kubeadm_join_secret.result["command"]}",
      "exit 0"
    ]
  }
  # provisioner "remote-exec" {
  #   when = "destroy"
  #   inline = [
  #     "sudo kubeadm reset --force --v 10",
  #   ]
  # }
}

resource "null_resource" "install_join_nodes" {
  # depends_on = ["null_resource.kubernetes"]
  count = length(var.k8s_node_private_ips)
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}" #${file("${path.module}/${var.aws_public_key}")}
    host        = "${element(var.k8s_node_private_ips, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo  ${data.external.kubeadm_join_node.result["command"]}",
      "exit 0" #trick it so I can reapply
    ]
  }
  # provisioner "remote-exec" {
  #   when = "destroy"
  #   inline = [
  #     "sudo kubeadm reset --force --v 10",
  #   ]
  # }
}

# resource "null_resource" "hack_create_a_directory_in_each" {
#   # depends_on = ["null_resource.kubernetes"]
#   count = length(var.k8s_node_private_ips)
#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = "${file("${path.root}/${var.aws_public_key}.pem")}" #${file("${path.module}/${var.aws_public_key}")}
#     host        = "${element(var.k8s_node_private_ips,count.index)}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "mkdir -p /home/ubuntu/consul-data/0"
#       "mkdir -p /home/ubuntu/consul-data/1"
#       "mkdir -p /home/ubuntu/consul-data/2"
#     ]
#   }
# }
resource "null_resource" "check_join" {
  depends_on = ["null_resource.install_join_nodes", "null_resource.install_join_masters"]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}" #${file("${path.module}/${var.aws_public_key}")}
    host        = "${element(var.k8s_master_private_ips, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubectl --kubeconfig /etc/kubernetes/admin.conf get nodes"
    ]
  }
}

# kubeadm join 10.63.134.255:6443 --token bqnwk8.iz88in63eh7dkm7y \
#   --discovery-token-ca-cert-hash sha256:8e69d159ea8417fa7c099dd60efc13a029ba4a1ec0c258534c880c55b20885b1 \
#   --experimental-control-plane --certificate-key 5bf15558f6376699b645bfe26c303497114934d51647b594241e689ceb8a538a

# kubeadm join 10.63.134.255:6443 --token bqnwk8.iz88in63eh7dkm7y \
#   --discovery-token-ca-cert-hash sha256:8e69d159ea8417fa7c099dd60efc13a029ba4a1ec0c258534c880c55b20885b1

#    kubeadm join 10.63.129.13:6443 --token k1hq24.g37onof2gk9ulv95 \
#      --discovery-token-ca-cert-hash sha256:3158c1230961f0b7cd2474d92c446a9511c065e1098a4346356dace154b63671 \
#      --experimental-control-plane --certificate-key dc27e5b2cf4d230c491567155f5ecd6ebf7d4be1cb8afc6b4a9b0c65d66e1f67

#  kubeadm join 10.63.129.13:6443 --token k1hq24.g37onof2gk9ulv95 \
#      --discovery-token-ca-cert-hash sha256:3158c1230961f0b7cd2474d92c446a9511c065e1098a4346356dace154b63671

#    kubeadm join 10.63.128.78:6443 --token wnln7b.stoh928s96gorf6h \
#      --discovery-token-ca-cert-hash sha256:496c2df6c33460bd5ac074b5e11f65a80304c96592476b505b854588f5b7b742 \
#      --experimental-control-plane --certificate-key f94674b2ee333895347c64e7cda0ffba8d61737033e2ca284619dd213c4ff831

#  Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
#  As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
#  "kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

#  Then you can join any number of worker nodes by running the following on each as root:

#  kubeadm join 10.63.128.78:6443 --token wnln7b.stoh928s96gorf6h \
#      --discovery-token-ca-cert-hash sha256:496c2df6c33460bd5ac074b5e11f65a80304c96592476b505b854588f5b7b742