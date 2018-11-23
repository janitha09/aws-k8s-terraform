variable "aws" {
  type    = "map"
  default = {
    # https://console.aws.amazon.com/iam/home?#/security_credential
    access_key = ""
    secret_key = ""
    # https://docs.aws.amazon.com/general/latest/gr/rande.html
    region     = "ap-northeast-2"
  }
}

variable "key" {
  type = "map"
  default = {
    name        = "terraform"
    private_key = "certs/id_rsa"
    public_key  = "certs/id_rsa.pub"
  }
}

variable "eip" {
  default = "0.0.0.0"
}


variable "kubernetes" {
  type = "map"
  default = {
    dnsAddress    = "master-dns-loadbalancer.aaa.com"
    podSubnet     = "10.244.0.0/16"
    serviceSubnet = "10.96.0.0/12"
    serviceDNS    = "10.96.0.10"
  }
}
