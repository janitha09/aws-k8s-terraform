module "masters" {
  source = "./modules/masters"
#
#  aws = {
#    access_key    = ""
#    secret_key    = ""
#    region        = "ap-northeast-2"
#  }
#
#  aws_instance = {
#   tag_name      = "cluster2"
#    ami           = "ami-06e7b9c5e0c4dd014"
#    instance_type = "t2.micro"
#  }
#
#
#  security_groups = ["launch-wizard-1"]
#
#  key = {
#    name          = "nilath"
#    private_key   = "/root/.ssh/id_rsa"
#    public_key    = "/root/.ssh/id_rsa.pub"
#  }

}

output "public_ip" {
  value = "${module.masters.public_ip}"
}



variable "server_hostname" {
  default = "node01"
}

# Ubuntu reference for hostnamectl: http://manpages.ubuntu.com/manpages/trusty/man1/hostnamectl.1.html
resource "null_resource" "set-hostname" {
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("modules/masters/certs/id_rsa")}"
    host = "${module.masters.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${module.masters.public_ip} > test.txt",
    ]
  }
}

  
/*
variable "long_key" {
  type = "string"
  default = <<EOF
This is a long key.
Running over several lines.
EOF
}
*/

