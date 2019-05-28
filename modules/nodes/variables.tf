variable "aws" {
  type    = "map"
}


variable "aws_instance" {
  type    = "map"
  default = {
    tag_name      = "janitha-k8s-node"
    ami           = "ami-0c55b159cbfafe1f0"
    count         = 0
    instance_type = "t2.xlarge"
  }
}


variable "security_groups" {
  type    = "list"
}

variable "aws_ec2_private_key"{
  type = "string"
}
# variable "key" {
#   # type = "map"
#   # default = {
#   #   name        = "janitha.jayaweera"
#   #   # private_key = "certs/id_rsa"
#   #   # public_key  = "certs/id_rsa.pub"
#   # }
# }

# variable "public_key" {}

# variable "eip" {}


# variable "kubernetes" {
#   type = "map"
# }