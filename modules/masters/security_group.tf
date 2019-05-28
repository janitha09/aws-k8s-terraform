############################
######### OUTBOUND #########
############################
# resource "aws_security_group" "outbound" {
#   name        = "${var.security_groups[1]}"
#   description = "Terraform K8S outbound"
#   egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#   }
# }
# ############################
# ########## INBOUND #########
# ############################
# resource "aws_security_group" "inbound" {
#   name        = "${var.security_groups[0]}"
#   description = "Terraform K8S inbound"
#   ingress {
#     description = "ssh"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
