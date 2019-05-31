############################
########### AWS ############
############################

provider "aws" {
  # access_key = "${var.aws["access_key"]}"
  # secret_key = "${var.aws["secret_key"]}"
  region = "${var.aws["region"]}"
}

# resource "aws_key_pair" "cluster" {
#   key_name   = "${var.key["name"]}"
#   # public_key = "${var.public_key}"
# }

resource "aws_instance" "cluster" {
  # depends_on = ["aws_key_pair.cluster"]
  ami             = "${var.aws_instance["ami"]}"
  count           = var.aws_instance["count"]
  instance_type   = var.aws_instance["instance_type"]
  key_name        = var.aws_ec2_private_key
  vpc_security_group_ids = ["sg-04712c95cfacd658a","sg-065108a3caad538a3","sg-5510ba1e"]
  # security_groups = var.security_groups
  root_block_device {
    volume_size = "30"
  }
  tags = {
    Name    = "janitha-k8s-HA-master-${count.index}"
    Team    = "janitha-master"
    Purpose = "janitha-master"
  }
}

############################
######### POST AWS #########
############################

#resource "aws_eip_association" "proxy_eip" {
#  depends_on = ["null_resource.etcd_execute", "null_resource.master-post"]
#  instance_id   = "${aws_instance.cluster.0.id}"
#  allocation_id = "${data.aws_eip.proxy_ip.id}"
#}

############################
########## OUTPUT ##########
############################

output "count" {
  value = var.aws_instance["count"]
}

output "id" {
  value = aws_instance.cluster.*.id
}

output "tags_name" {
  value = aws_instance.cluster.*.tags.Name
}

output "public_ip" {
  value = aws_instance.cluster.*.public_ip
}

output "private_ip" {
  value = aws_instance.cluster.*.private_ip
}

