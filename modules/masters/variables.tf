variable "aws" {
  type    = "map"
  default = {
    # https://console.aws.amazon.com/iam/home?#/security_credential
    # access_key = ""
    # secret_key = ""
    # https://docs.aws.amazon.com/general/latest/gr/rande.html
    region     = "us-east-2"
  }
}


variable "aws_instance" {
  type    = "map"
  default = {
    tag_name      = "janitha-k8s-master"
    ami           = "ami-0c55b159cbfafe1f0"
    count         = 3
    instance_type = "t2.large"
  }
}


variable "security_groups" {
  type    = "list"
  default = ["janitha"]
}

variable "key" {
  type = "map"
  default = {
    name        = "janitha.jayaweera"
    # private_key = "certs/id_rsa"
    # public_key  = "certs/id_rsa.pub"
  }
}

# variable "public_key" {}

# variable "eip" {}


# variable "kubernetes" {
#   type = "map"
# }
