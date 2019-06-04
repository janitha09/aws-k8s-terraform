
data "template_file" "ssh-node-join" {
  template = "${file("${path.module}/templates/kubeadm-config.tpl")}"

  vars = {
    NODE_PUBLIC_IP0="${element(var.node_public_ip, 0)}"
    # PRIVATEIP2="${element(var.private_ip, 1)}"
    # PRIVATEIP3="${element(var.private_ip, 2)}"
  }
}

# variable "master_public_ip" {
#   type = string
#   default = "ec2-54-70-218-172.us-west-2.compute.amazonaws.com"
# }
variable "node_public_ip" {
    type = string
    default = "ec2-54-186-163-128.us-west-2.compute.amazonaws.com"
}

# resource "null_resource" "join_node" {
# #   provisioner "local-exec" {
# #     command = "ssh -i ${file("${path.root}/janitha.jayaweera.pem")} ${var.master_public_ip} ls -la" 
# #   }

#   provisioner "local-exec" {
#       command = "ssh -i janitha.jayaweera.pem ${var.node_public_ip} ls -la"
#   }
# }

# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec):   kubeadm join 172.31.16.155:6443 --token jke2ys.lf9okzcpfx4aoi55 \
# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec):     --discovery-token-ca-cert-hash sha256:32d3b0b88bdb6e8d567b60303a9093201cd4bca0ee57d3d8cbe108c8cb4203fd \
# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec):     --experimental-control-plane --certificate-key b2f9f17044d8ef49397816213e994993cfd74419c9d5bb5d72d6f0e98aa600c6

# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): "kubeadm init phase upload-certs --experimental-upload-certs" to reload certs afterward.

# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): Then you can join any number of worker nodes by running the following on each as root:

# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): kubeadm join 172.31.16.155:6443 --token jke2ys.lf9okzcpfx4aoi55 \
# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec):     --discovery-token-ca-cert-hash sha256:32d3b0b88bdb6e8d567b60303a9093201cd4bca0ee57d3d8cbe108c8cb4203fd
# module.kubernetes_first_master.null_resource.run-kubeadm: Creation complete after 6m23s [id=6869486592372491858]

