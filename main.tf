############################
########## MASTER ##########
############################
# creat LB classic
# https://medium.com/@hagaibarel/kubernetes-and-elbs-the-hard-way-c59a15779caf
module "masters" {
  source = "./modules/masters"

  # aws = "${var.aws}"
  # key = "${var.key}"
  # public_key = "${data.template_file.public_key.rendered}"
  # kubernetes = "${var.kubernetes}"

  # move eip to post processing
  # eip = "${var.eip}"
}

module "nodes" {
  source = "./modules/nodes"

  # aws = "${var.aws}"
  # key = "${var.key}"
  # public_key = "${data.template_file.public_key.rendered}"
  # kubernetes = "${var.kubernetes}"

  # move eip to post processing
  # eip = "${var.eip}"
}

locals {
  master_count = "${module.masters.count}"
  master_id = "${module.masters.id}"
  master_public_ip = "${module.masters.public_ip}"
  master_private_ip = "${module.masters.private_ip}"
  master_tags_name = "${module.masters.tags_name}"
}

locals {
  node_count = "${module.nodes.count}"
  node_id = "${module.nodes.id}"
  node_public_ip = "${module.nodes.public_ip}"
  node_private_ip = "${module.nodes.private_ip}"
  node_tags_name = "${module.nodes.tags_name}"
}

output "master" {
  value = {
    count = "${local.master_count}"
    id = "${local.master_id}"
    public_ip = "${local.master_public_ip}"
    private_ip = "${local.master_private_ip}"
    tags_name = "${local.master_tags_name}"
  }
}
output "node" {
  value = {
    count = "${local.node_count}"
    id = "${local.node_id}"
    public_ip = "${local.node_public_ip}"
    private_ip = "${local.node_private_ip}"
    tags_name = "${local.node_tags_name}"
  }
}

resource "null_resource" "master" {
  depends_on = ["module.masters"]

  count = "${local.master_count}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    # private_key = "${data.template_file.private_key.rendered}"
    host        = "${local.master_public_ip}"
  }

  provisioner "local-exec" {
    command = "echo '${element(local.master_public_ip, count.index)}' >> test"
  }
}

resource "null_resource" "node" {
  depends_on = ["module.nodes"]

  count = "${local.node_count}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    # private_key = "${data.template_file.private_key.rendered}"
    host        = "${local.node_public_ip}"
  }

  provisioner "local-exec" {
    command = "echo '${element(local.node_public_ip, count.index)}' >> test"
  }
}
# not needed in 1.14
# module "etcd" {
#   source ="./modules/etcd"

#   count      = "${local.count}"
#   id         = "${local.id}"
#   public_ip  = "${local.public_ip}"
#   private_ip = "${local.private_ip}"
#   key = "${var.key}"
#   public_key = "${data.template_file.public_key.rendered}"
#   private_key = "${data.template_file.private_key.rendered}"
# }

module "kubernetes_master" {
  source ="./modules/kubernetes"

  count      = "${local.master_count}"
  id         = "${local.master_id}"
  public_ip  = "${local.master_public_ip}"
  private_ip = "${local.master_private_ip}"
  key        = "${var.key}"
  # public_key = "${data.template_file.public_key.rendered}"
  # private_key = "${data.template_file.private_key.rendered}"
  # kubernetes = "${var.kubernetes}"
}
  
  module "kubernetes_node" {
  source ="./modules/kubernetes"

  count      = "${local.node_count}"
  id         = "${local.node_id}"
  public_ip  = "${local.node_public_ip}"
  private_ip = "${local.node_private_ip}"
  key        = "${var.key}"
  # public_key = "${data.template_file.public_key.rendered}"
  # private_key = "${data.template_file.private_key.rendered}"
  # kubernetes = "${var.kubernetes}"
}
/*
variable "long_key" {
  type = "string"
  default = <<EOF
This is a long key.
Running over several lines.
EOF
}
*/
# https://stackoverflow.com/questions/44509997/capture-terraform-provisioner-output
# resource "null_resource" "contents" {
#   triggers = {
#     stdout     = "${data.external.read.result["stdout"]}"
#     stderr     = "${data.external.read.result["stderr"]}"
#     exitstatus = "${data.external.read.result["exitstatus"]}"
#   }

#   lifecycle {
#     ignore_changes = [
#       "triggers",
#     ]
#   }
# }
