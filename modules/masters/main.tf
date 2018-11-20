############################
########### AWS ############
############################

provider "aws" {
  access_key = "${var.aws["access_key"]}"
  secret_key = "${var.aws["secret_key"]}"
  region     = "${var.aws["region"]}"
}

resource "aws_key_pair" "cluster" {
  key_name   = "${var.key["name"]}"
  public_key = "${file("${path.module}/${var.key["public_key"]}")}"
}

resource "aws_instance" "cluster" {
  depends_on = ["aws_key_pair.cluster"]
  ami             = "${var.aws_instance["ami"]}"
  count           = "${var.aws_instance["count"]}"
  instance_type   = "${var.aws_instance["instance_type"]}"
  key_name        = "${var.key["name"]}"
  security_groups = "${var.security_groups}"

  tags {
    Name = "master${count.index}"
  }
}



############################
######### POST AWS #########
############################

#resource "aws_eip_association" "proxy_eip" {
#  depends_on = ["null_resource.etcd_execute"]
#  instance_id   = "${aws_instance.cluster.0.id}"
#  allocation_id = "${data.aws_eip.proxy_ip.id}"
#}

