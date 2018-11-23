############################
########## MASTER ##########
############################

module "masters" {
  source = "./modules/masters"

  aws = "${var.aws}"
  key = "${var.key}"
  public_key = "${data.template_file.public_key.rendered}"
  kubernetes = "${var.kubernetes}"

  # move eip to post processing
  eip = "${var.eip}"
}

locals {
  count = "${module.masters.count}"
  id = "${module.masters.id}"
  public_ip = "${module.masters.public_ip}"
  private_ip = "${module.masters.private_ip}"
  tags_name = "${module.masters.tags_name}"
}

output "aws" {
  value = {
    count = "${local.count}"
    id = "${local.id}"
    public_ip = "${local.public_ip}"
    private_ip = "${local.private_ip}"
    tags_name = "${local.tags_name}"
  }
}

resource "null_resource" "master" {
  depends_on = ["module.masters"]

  count = "${local.count}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${data.template_file.private_key.rendered}"
    host        = "${local.public_ip}"
  }

  provisioner "local-exec" {
    command = "echo '${element(local.public_ip, count.index)}' >> test"
  }
}

module "etcd" {
  source ="./modules/etcd"

  count      = "${local.count}"
  id         = "${local.id}"
  public_ip  = "${local.public_ip}"
  private_ip = "${local.private_ip}"
  key = "${var.key}"
  public_key = "${data.template_file.public_key.rendered}"
  private_key = "${data.template_file.private_key.rendered}"
}

module "kubernetes" {
  source ="./modules/kubernetes"

  count      = "${local.count}"
  id         = "${local.id}"
  public_ip  = "${local.public_ip}"
  private_ip = "${local.private_ip}"
  key = "${var.key}"
  public_key = "${data.template_file.public_key.rendered}"
  private_key = "${data.template_file.private_key.rendered}"
  kubernetes = "${var.kubernetes}"
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

