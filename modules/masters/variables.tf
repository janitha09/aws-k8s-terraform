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
  default = ["launch-wizard-1"]
}


variable "key" {
  type = "map"
  default = {
    name        = "fo4-team-terraform"
    private_key = "certs/id_rsa"
    public_key  = "certs/id_rsa.pub"
  }
}

#variable "eip" {
#  default = "0.0.0.0"
#}
