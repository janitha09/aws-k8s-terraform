variable "aws" {
  type        = map(string)
  description = "set region"
  default = {
    # https://console.aws.amazon.com/iam/home?#/security_credential
    # access_key = ""
    # secret_key = ""
    # https://docs.aws.amazon.com/general/latest/gr/rande.html
    region = "us-west-2"
  }
}

variable "aws_instance" {
  type = map(string)
  default = {
    tag_name      = "janitha-k8s-haproxy"
    ami           = "ami-005bdb005fb00e791"
    instance_type = "t2.micro"
  }
}

variable "security_groups" {
  type    = list(string)
  default = ["janitha"]
}

variable "k8s_master_private_ips" {
  type = list
  default = [
    "172.31.19.250",
    "172.31.30.55",
    "172.31.26.209"
  ]
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

variable "aws_public_key" {
  type = string
}