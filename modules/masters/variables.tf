variable "aws" {
  type = map(string)
}

variable "aws_instance" {
  type = map(string)
  default = {
    tag_name      = "janitha-k8s-master"
    ami           = "ami-005bdb005fb00e791" #"ami-0c55b159cbfafe1f0"
    count         = 1
    instance_type = "t2.large"
  }
}

variable "security_groups" {
  type = list(string)
}

variable "aws_ec2_private_key" {
  type = string
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
