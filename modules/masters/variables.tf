variable "aws" {
  type    = "map"
}


variable "aws_instance" {
  type    = "map"
  default = {
    tag_name      = "master"
    ami           = "ami-06e7b9c5e0c4dd014"
    count         = 3
    instance_type = "t2.micro"
  }
}


variable "security_groups" {
  type    = "list"
  default = ["aws-terraform-inbound", "aws-terraform-outbound"]
}


variable "key" {
  type = "map"
}

variable "public_key" {}

variable "eip" {}


variable "kubernetes" {
  type = "map"
}
