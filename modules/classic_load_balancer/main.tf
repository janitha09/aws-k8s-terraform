provider "aws" {
  region     = "${var.aws["region"]}"
}
resource "aws_elb" "load_balancer" {
    name = "janitha"
    availability_zones = ["us-east-2a","us-east-2b"]
    # region = "${var.aws[region]}"
    security_groups= "${var.security_groups}"
  
  listener {
    instance_port     = 6443
    instance_protocol = "ssl"
    lb_port           = 6443
    lb_protocol       = "ssl"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "SSL:6443"
    interval            = 30
  }
  instances                   = "${var.id}"
}


output "dns_name" {
  value = "${aws_elb.load_balancer.dns_name}"
}

output "instances" {
  value = "${aws_elb.load_balancer.instances}"
}

output "listener_0" {
  value = "${aws_elb.load_balancer.listener}"
}
