
provider "aws" {
  region = "${var.aws["region"]}"
}

resource "aws_security_group" "self" {
  name = "${var.tag-environment}-k8s-security-group"
  # region = "${var.aws["region"]}"
  description = "SG for EC2 created for Enviroment ${var.tag-environment}"
  vpc_id      = "vpc-01283229a10bf286a" #"${aws_vpc.main.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # prefix_list_ids = ["pl-12c4e678"]
  }
}

output "security_group" {
  value = {
    id          = aws_security_group.self.id
    arn         = aws_security_group.self.arn
    vpc_id      = aws_security_group.self.vpc_id
    owner_id    = aws_security_group.self.owner_id
    name        = aws_security_group.self.name
    description = aws_security_group.self.description
    ingress     = aws_security_group.self.ingress
    egress      = aws_security_group.self.egress
  }
}

module "masters" {
  source                 = "./modules/masters"
  aws                    = var.aws
  aws_public_key         = var.aws_public_key
  vpc_security_group_ids = ["${aws_security_group.self.id}"]
  subnet_id              = var.subnet_id
  tag-environment        = var.tag-environment
}

output "masters" {
  value = {
    count       = module.masters.count
    id          = module.masters.id
    public_ip   = module.masters.public_ip
    private_ip  = module.masters.private_ip
    tags_name   = module.masters.tags_name
    other_stuff = module.masters.other_stuff
    # arn = module.masters.arn
    # availability_zone = module.masters.availability_zone

  }
}

module "haproxy" {
  source                 = "./modules/haproxy"
  aws                    = var.aws
  k8s_master_private_ips = module.masters.private_ip
  vpc_security_group_ids = ["${aws_security_group.self.id}"]
  subnet_id              = var.subnet_id
  aws_public_key         = var.aws_public_key
  tag-environment        = var.tag-environment
}

output "haproxy" {
  value = {
    # haproxy_count      = module.haproxy.count
    id          = module.haproxy.id
    public_ip   = module.haproxy.public_ip
    private_ip  = module.haproxy.private_ip
    tags_name   = module.haproxy.tags_name
    other_stuff = module.haproxy.other_stuff
  }
}

module "nodes" {
  source                 = "./modules/nodes"
  aws                    = var.aws
  vpc_security_group_ids = ["${aws_security_group.self.id}"]
  subnet_id              = var.subnet_id
  tag-environment        = var.tag-environment
  aws_public_key         = var.aws_public_key
}

output "nodes" {
  value = {
    count       = module.nodes.count
    id          = module.nodes.id
    public_ip   = module.nodes.public_ip
    private_ip  = module.nodes.private_ip
    tags_name   = module.nodes.tags_name
    other_stuff = module.nodes.other_stuff
  }
}
module "kubernetes_master" {
  source         = "./modules/kubernetes"
  instances      = module.masters.count
  private_ip     = module.masters.private_ip
  aws_public_key = var.aws_public_key
}

module "kubernetes_node" {
  source         = "./modules/kubernetes"
  instances      = module.nodes.count
  private_ip     = module.nodes.private_ip
  aws_public_key = var.aws_public_key
}
module "kubernetes_first_master" {
  source                                 = "./modules/first_master"
  master_private_ip                      = "${module.masters.private_ip}"
  haproxy_private_ip                     = "${module.haproxy.private_ip}"
  kubernetes_installed_on_master_atleast = "${module.kubernetes_master.kubernetes_installed_on_master_atleast}"
  aws_public_key                         = var.aws_public_key
}

module "create_ha_kube_cluster" {
  # depends_on = ["module.kubernetes_first_master"]
  source                        = "./modules/join_master_node"
  k8s_master_private_ips        = module.masters.private_ip
  k8s_node_private_ips          = module.nodes.private_ip
  k8s_installed_on_first_master = "${module.kubernetes_first_master.k8s_installed_on_first_master}"
  aws_public_key                = var.aws_public_key
}
/*
-variable "long_key" {
-  type = "string"
-  default = <<EOF
-This is a long key.
-Running over several lines.
-EOF
-}
-*/
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
# https://www.terraform.io/docs/providers/aws/r/key_pair.html
# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
# }

