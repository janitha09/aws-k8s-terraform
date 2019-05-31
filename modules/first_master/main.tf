
resource "null_resource" "kubeadm-config" {
  triggers = {
    cluster_instance_ids = "${join(",", var.public_ip)}"
  }

  count = 1
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/janitha.jayaweera.pem")}"
    host        = "${element(var.public_ip, count.index)}"
  }

  provisioner "file" {
    content     = "${element(data.template_file.kubeadm-config.*.rendered, 1)}"
    destination = "/home/ubuntu/haproxy/kubeadm-config.yaml"
  }
  # provisioner "file" {
  #   source      = "${path.module}/templates/kubeadm-config.tpl"
  #   destination = "/home/ubuntu/kubeadm-config.yaml"
  # }

#   provisioner "file" {
#     content     = "${data.template_file.10-kubeadm-conf.rendered}"
#     destination = "/home/ubuntu/10-kubeadm.conf"
#   }

#   provisioner "file" {
#     content     = "${element(data.template_file.kubeadm-config-yaml.*.rendered, count.index)}"
#     destination = "/home/ubuntu/kubeadm.config.yaml"
#   }
}
# ### MASTER ###

resource "null_resource" "run-kubeadm" {
  depends_on = ["null_resource.kubeadm-config"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/janitha.jayaweera.pem")}"
    host        = "${element(var.public_ip, 0)}"
  }

# https://github.com/stillinbeta/srecon-k8s-tutorial/blob/46152b4f1c184f07d49f25a81b780950aebb4822/tutorial1.md
  provisioner "remote-exec" {
    inline = [
      # "sudo cp -r /etc/kubernetes/pki_LB/* /etc/kubernetes/pki/",
      "sudo kubeadm init --config /home/ubuntu/kubeadm-config.yaml --experimental-upload-certs --v 10" #--pod-network-cidr=192.168.0.0/16
      # "sudo kubeadm reset --force --v 10",
      # "sudo kubeadm init phase preflight --config /home/ubuntu/kubeadm-config.yaml --v 10",
      # "sudo kubeadm init phase certs all --config ~/kubeadm-config.yaml --v 10",
      # "sudo cp -r /etc/kubernetes/pki_LB/* /etc/kubernetes/pki/", # preserve certs on the LB
      # "sudo kubeadm init phase kubeconfig all --config /home/ubuntu/kubeadm-config.yaml",
      # "sudo kubeadm init phase kubelet-start --config ~/kubeadm-config.yaml --v 10", # does n't really start Failed to list *v1.Node: the server is currently unable to handle the request (get nodes)
      # "sudo kubeadm init phase control-plane all --config ~/kubeadm-config.yaml --v 10",
      # "sudo kubeadm init phase etcd local --config ~/kubeadm-config.yaml --v 10",
      # "sudo kubeadm init phase kubelet-start --config ~/kubeadm-config.yaml --v 10", # update docs to say run this later? https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init-phase/#cmd-phase-upload-certs
      # "sudo kubeadm init phase upload-certs --config ~/kubeadm-config.yaml --experimental-upload-certs --v 10", # this does not work
      # "sudo kubeadm init phase mark-control-plane --config ~/kubeadm-config.yaml --v 10", # cannot get to the node kubectl is trying to connect to localhost
      # "sudo kubeadm init phase bootstrap-token --config ~/kubeadm-config.yaml --v 10", #this fails because of secrets
      # "sudo kubeadm init phase upload-config all --config ~/kubeadm-config.yaml --v 10",
      # "sudo kubeadm init phase addon all --config ~/kubeadm-config.yaml --v 10" # --pod-network-cidr 192.168.0.0/16

      # The traffic is going through but a curl doesn't work
    #   "sudo tar cvfz /tmp/cred.tar.gz /etc/kubernetes/pki/sa.* /etc/kubernetes/pki/ca.*"
    ]
  }

    provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "sudo kubeadm reset --force --v 10",
    ]
  }

#   provisioner "local-exec" {
#     command = "scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i ${path.module}/certs/id_rsa ubuntu@${element(var.public_ip, 0)}:/tmp/cred.tar.gz /tmp/cred.tar.gz"
#   }
}




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

data "template_file" "kubeadm-config" {
  template = "${file("${path.module}/templates/kubeadm-config.tpl")}"

  vars = {
    HAPROXY_IP="${element(var.haproxy_ip, 1)}"
    # PRIVATEIP2="${element(var.private_ip, 1)}"
    # PRIVATEIP3="${element(var.private_ip, 2)}"
  }
}

# resource "null_resource" "create_haproxy_cfg" {
#   depends_on = ["null_resource.haproxy_execute"]

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = "${file("${path.root}/janitha.jayaweera.pem")}"
#     host        = "${element(var.public_ip, 0)}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "mkdir -p /home/ubuntu/haproxy"
#     ]
#   }

#   provisioner "file" {
#     content     = "${element(data.template_file.haproxy-cfg.*.rendered, 1)}"
#     destination = "/home/ubuntu/haproxy/haproxy.cfg"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "bash -c 'cat > /home/ubuntu/haproxy/Dockerfile << EOF",
#       "FROM haproxy:latest",
#       "COPY ./haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg",
#       "EOF'",
#       "docker build -t haproxy_master_lb:latest /home/ubuntu/haproxy",
#       "docker run -d -p 6443:6443 haproxy_master_lb:latest"
#     ]
#   }
# }