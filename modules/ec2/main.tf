# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"
provider "aws" {
  region = "us-east-2"
}

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-18.*-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

# # "${data.aws_ami.ubuntu.id}"
# resource "aws_instance" "t2_micro" {
#   ami           = "ami-0c55b159cbfafe1f0"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "t2_micro"
#   }
# }
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.example.id}"
  instance_id = "${aws_instance.web.id}"
}

resource "aws_instance" "web" {
  ami               = "ami-0c55b159cbfafe1f0"
  availability_zone = "us-east-2a"
  instance_type     = "t2.micro"
  key_name = "janitha.jayaweera"
#   "${aws_key_pair.janitha.key_name}"
  vpc_security_group_ids = ["janitha"]
  root_block_device = {
      volume_size = 30
  }
  tags = {
    Name = "HelloWorld"
  }
}
# # ssh-keygen -y -f janitha.jayaweera.pem
# resource "aws_key_pair" "janitha" {
#   key_name   = "janitha-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgCrkJKqUzFbiwGK69PtR0m43gHd/CvdoN3nG/g87zS5x3uIc0QpSQQbHJdMbJNQtDvBWLHsTwBSg0Iyn+diVAjINTmi86fE53OQzTrJLtpGdqAFc7g7hFLOTGHPh43eADdwgUaAjbtYYneMEiK1qHIiECou1KxJURRu79Tl4kVj5s6DdsvzjkSGl2X1m8PFoSIqnTXyKQFyGBhusfN0h7tJr5SyFeYp7CggAbYC8fcU1mIdgM+zwQNACOF45cz2EQi8WdmOejm2tQkvfbwbW4PQbRLe69iU7xVy+/QYKrAOyCGlaL0+K01lupiOuT8fSsRK9V3ZHEQk3bfwKBct0B"
# }


resource "aws_ebs_volume" "example" {
  availability_zone = "us-east-2a"
  size              = 1
}

# resource "aws_ami" "example" {
#   name                = "terraform-example"
#   virtualization_type = "hvm"
#   root_device_name    = "/dev/xvda"

#   ebs_block_device {
#     device_name = "/dev/xvda"
#     # snapshot_id = "snap-xxxxxxxx"
#     volume_size = 30
#   }
# }
