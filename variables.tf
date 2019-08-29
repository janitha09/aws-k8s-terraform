variable "aws" {
  type = map(string)
  default = {
    region = "us-west-2"
  }
}

# variable "key" {
#   type = map(string)
#   default = {
#     name = "janitha.jayaweera.525546773638"
#   }
# }

variable "security_groups" {
  type    = list(string)
  default = ["janitha"]
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = ["sg-0887630f35d971bb3"]
}
variable "subnet_id" {
  type    = string
  default = "subnet-01d7dbef939fa5823"
}

variable "tag-environment" {
  type    = string
  default = "Janitha"
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
variable "aws_public_key" {
  type    = string
  default = "janitha.jayaweera.525546773638"
}