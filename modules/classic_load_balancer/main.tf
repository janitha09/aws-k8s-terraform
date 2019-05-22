provider "aws" {
  region     = "${var.aws["region"]}"
}
resource "aws_elb" "load_balancer" {
    name = "janitha-k8s-HA-master-LB"
    availability_zones = ["us-east-2a","us-east-2b"]
    # region = "${var.aws[region]}"
    security_groups= ["${var.security_groups}"]
  
  listener {
    instance_port     = 6443
    instance_protocol = "http"
    lb_port           = 6443
    lb_protocol       = "http"
  }
  instances                   = ["${var.id}"]
}
