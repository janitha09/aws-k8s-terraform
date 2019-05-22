variable "id" {
  type = "list"
  # default = ["i-05b367984395769d1"]
}

variable "security_groups" {
  type    = "list"
  default = ["sg-0d77b0ea0703ea786"]
}
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