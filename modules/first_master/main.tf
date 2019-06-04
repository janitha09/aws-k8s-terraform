
resource "null_resource" "kubeadm-config" {
  # triggers = {
  #   cluster_instance_ids = "${join(",", var.master_public_ip)}"
  # }

  count = 1
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/janitha.jayaweera.pem")}"
    host        = "${element(var.master_public_ip, count.index)}"
  }

  provisioner "file" {
    content     = "${element(data.template_file.kubeadm-config.*.rendered, 0)}"
    destination = "/home/ubuntu/kubeadm-config.yaml"
  }
}
resource "null_resource" "run-kubeadm" {
  depends_on = ["null_resource.kubeadm-config"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/janitha.jayaweera.pem")}"
    host        = "${element(var.master_public_ip, 0)}"
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
    ]
  }

    provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "sudo kubeadm reset --force --v 10",
    ]
  }
}

# resource "null_resource" "master_join_token" {
#   depends_on = ["null_resource.run-kubeadm"]
#   provisioner "local-exec" {
#     command = 
#   }
# }
# You can now join any number of the control-plane node running the following command on each as root:

# kubeadm join 172.31.16.155:6443 --token jke2ys.lf9okzcpfx4aoi55 \
# --discovery-token-ca-cert-hash sha256:32d3b0b88bdb6e8d567b60303a9093201cd4bca0ee57d3d8cbe108c8cb4203fd \
# --experimental-control-plane --certificate-key b2f9f17044d8ef49397816213e994993cfd74419c9d5bb5d72d6f0e98aa600c6

# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): "kubeadm init phase upload-certs --experimental-upload-certs" to reload certs afterward.

# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join 172.31.16.155:6443 --token jke2ys.lf9okzcpfx4aoi55 \
# --discovery-token-ca-cert-hash sha256:32d3b0b88bdb6e8d567b60303a9093201cd4bca0ee57d3d8cbe108c8cb4203fd







data "template_file" "kubeadm-config" {
  template = "${file("${path.module}/templates/kubeadm-config.tpl")}"

  vars = {
    HAPROXY_PRIVATE_IP="${element(var.haproxy_private_ip, 0)}"
    # PRIVATEIP2="${element(var.private_ip, 1)}"
    # PRIVATEIP3="${element(var.private_ip, 2)}"
  }
}
