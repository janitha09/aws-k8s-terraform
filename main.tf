module "masters" {
  source = "./modules/masters"

  aws                 = var.aws
  security_groups     = var.security_groups
  aws_ec2_private_key = var.aws_ec2_private_key
}

module "haproxy" {
  source = "./modules/haproxy"
  aws                 = var.aws
  security_groups     = var.security_groups
  aws_ec2_private_key = var.aws_ec2_private_key
  k8s_master_ips = module.masters.public_ip
}


module "nodes" {
  source = "./modules/nodes"

  aws                 = var.aws
  security_groups     = var.security_groups
  aws_ec2_private_key = var.aws_ec2_private_key
}

module "kubernetes_master" {
  source = "./modules/kubernetes"
  instances      = module.masters.count
  id         = module.masters.id
  public_ip  = module.masters.public_ip
  private_ip = module.masters.private_ip
  key        = var.key
}

module "kubernetes_node" {
  source = "./modules/kubernetes"

  instances      = module.nodes.count
  id         = module.nodes.id
  public_ip  = module.nodes.public_ip
  private_ip = module.nodes.private_ip
  key        = var.key
}

module "kubernetes_first_master" {
  source = "./modules/first_master"
  public_ip  = "${module.masters.public_ip}"
  haproxy_ip = "${module.haproxy.public_ip}"
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
