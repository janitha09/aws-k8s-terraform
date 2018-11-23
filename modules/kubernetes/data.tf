############################
########### DATA ###########
############################

data "template_file" "10-kubeadm-conf" {
  template = "${file("${path.module}/templates/10-kubeadm.conf")}"

  vars {
    SERVICEDNS="${var.kubernetes["serviceDNS"]}"
    PRIVATEIP="${element(var.private_ip, count.index)}"
  }
}

data "template_file" "kubeadm-config-yaml" {
  template = "${file("${path.module}/templates/kubeadm.config.yaml")}"
  count = "${var.count}"

  vars {
    DNSADDRESS="${var.kubernetes["dnsAddress"]}"
    MASTERSCOUNT="${var.count}"
    SERVICESUBNET="${var.kubernetes["serviceSubnet"]}"
    PODSUBNET="${var.kubernetes["podSubnet"]}"
    PRIVATEIP="${element(var.private_ip, count.index)}"
    PRIVATEIP1="${element(var.private_ip, 0)}"
    PRIVATEIP2="${element(var.private_ip, 1)}"
    PRIVATEIP3="${element(var.private_ip, 2)}"
  }
}

