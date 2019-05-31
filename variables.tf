variable "aws" {
  type = map(string)
  default = {
    # https://console.aws.amazon.com/iam/home?#/security_credential
    # access_key = ""
    # secret_key = ""
    # https://docs.aws.amazon.com/general/latest/gr/rande.html
    region = "us-west-2"
  }
}

variable "key" {
  type = map(string)
  default = {
    name = "janitha.jayaweera.525546773638"
  }
}

variable "security_groups" {
  type    = list(string)
  default = ["janitha"]
}

variable "aws_ec2_private_key" {
  type    = string
  default = "janitha.jayaweera.525546773638"
}

# variable "eip" {
#   default = "0.0.0.0"
# }
# variable "kubernetes" {
#   type = "map"
#   default = {
#     dnsAddress    = "master-dns-loadbalancer.aaa.com"
#     podSubnet     = "10.244.0.0/16"
#     serviceSubnet = "10.96.0.0/12"
#     serviceDNS    = "10.96.0.10"
#   }
# }
