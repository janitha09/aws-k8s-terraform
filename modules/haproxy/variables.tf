variable "aws" {
  type = map(string)
  description = "set region"
  default = {
    # https://console.aws.amazon.com/iam/home?#/security_credential
    # access_key = ""
    # secret_key = ""
    # https://docs.aws.amazon.com/general/latest/gr/rande.html
    region = "us-east-2"
  }
}

variable "aws_instance" {
  type = map(string)
  default = {
    tag_name      = "janitha-k8s-haproxy"
    ami           = "ami-0c55b159cbfafe1f0"
    count         = 1
    instance_type = "t2.micro"
  }
}

variable "security_groups" {
  type    = list(string)
  default = ["janitha"]
}

variable "aws_ec2_private_key" {
  type    = string
  default = "janitha.jayaweera"
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
