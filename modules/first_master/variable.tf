variable "master_public_ip" {
  type = "list"
  default = ["ec2-34-217-214-78.us-west-2.compute.amazonaws.com"]
}
variable "haproxy_private_ip"{
  type = "list"
  default = ["172.31.18.244"]
}