variable "master_private_ip" {
  type    = "list"
  default = ["ec2-54-213-119-155.us-west-2.compute.amazonaws.com"]
}
variable "haproxy_private_ip" {
  type    = "list"
  default = ["172.31.18.244"]
}

variable "kubernetes_installed_on_master_atleast" {
  type = string
}

variable "istio-version" {
  type    = string
  default = "1.2.2"
}

variable "calico-version" {
  type    = string
  default = "v3.8"
}
variable "aws_public_key" {
  type = string
}