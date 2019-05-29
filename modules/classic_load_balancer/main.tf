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

resource "aws_lb" "pass_through" {
  name = "janitha_nlb"
  load_balancer_type = "network"
  
  access_logs {
    bucket  = "s3://janitha-nlb"
    prefix  = "pass-through"
    enabled = true
  }
}

resource "aws_lb_listener" "pass_through" {
  load_balancer_arn = "${aws_lb.pass_through.arn}"
  port              = "6443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-2:369551733582:certificate/07434d6b-249d-41cc-953f-3b418058b8b1"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.pass_through.arn}"
  }
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
