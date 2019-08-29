variable "aws" {
  type        = map(string)
  description = "set region"
  default = {
    region = "us-west-2"
  }
}

variable "aws_instance" {
  type = map(string)
  default = {
    tag_name      = "janitha-k8s-master"
    ami           = "ami-005bdb005fb00e791" #"ami-0c55b159cbfafe1f0"
    count         = 3
    instance_type = "t2.large"
  }
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = ["sg-0887630f35d971bb3"] #,"${local.local_self_security_group}"]
}
variable "subnet_id" {
  type    = string
  default = "subnet-01d7dbef939fa5823"
}
variable "tag-environment" {
  type    = string
  default = "Janitha"
}
variable "aws_public_key" {
  type = string
}

