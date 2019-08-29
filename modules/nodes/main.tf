############################
########### AWS ############
############################

provider "aws" {
  region = "${var.aws["region"]}"
}

# resource "aws_security_group" "self" {
#   name = "${var.tag-environment}-k8s-security-group"
#   # region = "${var.aws["region"]}"
#   description = "SG for EC2 created for Enviroment ${var.tag-environment}"
#   vpc_id      = "vpc-01283229a10bf286a" #"${aws_vpc.main.id}"

#   ingress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     self      = true
#   }

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     # prefix_list_ids = ["pl-12c4e678"]
#   }
# }
# resource "aws_key_pair" "cluster" {
#   key_name   = "${var.key["name"]}"
#   # public_key = "${var.public_key}"
# }

resource "aws_instance" "k8s_nodes" {
  ami                    = "${var.aws_instance["ami"]}"
  count                  = var.aws_instance["count"]
  instance_type          = var.aws_instance["instance_type"]
  key_name               = var.aws_public_key
  vpc_security_group_ids = var.vpc_security_group_ids # ["${aws_security_group.self.id}"] #var.vpc_security_group_ids #
  subnet_id              = var.subnet_id

  root_block_device {
    volume_size = "30"
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_type           = "gp2"
    volume_size           = 100
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name    = "${var.tag-environment}-k8s-HA-nodes-${count.index}"
    Team    = "${var.tag-environment}-team"
    Purpose = "${var.tag-environment}-play"
  }
}

resource "null_resource" "mount_xvdb" {
  # depends_on = ["aws_instace.k8s_nodes"]git 
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(aws_instance.k8s_nodes.*.private_ip, 0)}"
  }
  #   provisioner "file" {
  #   windows copy ^M
  #   source      = "scripts/attach_ebs.sh"
  #   destination = "/home/ubuntu/attach_ebs.sh"
  # }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs -t ext4 /dev/xvdb",
      "sudo mkdir /data",
      "sudo mount /dev/xvdb /data",
      "sudo bash -c 'echo /dev/xvdb  /data ext4 defaults,nofail 0 2 >> /etc/fstab'"
    ]
  }
}

# https://medium.com/@devopslearning/aws-iam-ec2-instance-role-using-terraform-fa2b21488536
resource "aws_iam_role" "janitha_k8s_node_role" {
  name = "${var.tag-environment}_k8s_node_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "${var.tag-environment}_k8s_node_role"
  }
}

resource "aws_iam_instance_profile" "janitha_k8s_node_profile" {
  name = "${var.tag-environment}_k8s_node_profile"
  role = "${aws_iam_role.janitha_k8s_node_role.name}"
}

resource "aws_iam_policy" "node_policy" {
  name = "${var.tag-environment}_k8s_node"
  path = "/"
  description = "k8s node policy https://github.com/kubernetes/cloud-provider-aws#readme"

  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ec2:DescribeInstances",
                  "ec2:DescribeRegions",
                  "ecr:GetAuthorizationToken",
                  "ecr:BatchCheckLayerAvailability",
                  "ecr:GetDownloadUrlForLayer",
                  "ecr:GetRepositoryPolicy",
                  "ecr:DescribeRepositories",
                  "ecr:ListImages",
                  "ecr:BatchGetImage"
              ],
              "Resource": "*"
          } 
      ]
}
  EOF
}

output "count" {
  value = "${var.aws_instance["count"]}"
}

output "id" {
  value = "${aws_instance.k8s_nodes.*.id}"
}

output "tags_name" {
  value = "${aws_instance.k8s_nodes.*.tags.Name}"
}

output "public_ip" {
  value = "${aws_instance.k8s_nodes.*.public_ip}"
}

output "private_ip" {
  value = "${aws_instance.k8s_nodes.*.private_ip}"
}

output "other_stuff" {
  value = {
    arn                    = aws_instance.k8s_nodes.*.arn
    availability_zone      = aws_instance.k8s_nodes.*.availability_zone
    subnet_id              = aws_instance.k8s_nodes.*.subnet_id
    security_groups        = aws_instance.k8s_nodes.*.vpc_security_group_ids
    vpc_security_group_ids = aws_instance.k8s_nodes.*.vpc_security_group_ids
    key_name               = aws_instance.k8s_nodes.*.key_name
    placement_group        = aws_instance.k8s_nodes.*.placement_group
  }
}

# https://github.com/kubernetes-sigs/kubespray/blob/master/contrib/terraform/aws/create-infrastructure.tf
# add permissions to create volumes

# resource "aws_instance" "k8s-worker" {
#   ami           = "${data.aws_ami.distro.id}"
#   instance_type = "${var.aws_kube_worker_size}"

#   count = "${var.aws_kube_worker_num}"

#   availability_zone = "${element(slice(data.aws_availability_zones.available.names,0,2),count.index)}"
#   subnet_id         = "${element(module.aws-vpc.aws_subnet_ids_private,count.index)}"

#   vpc_security_group_ids = ["${module.aws-vpc.aws_security_group}"]

#   iam_instance_profile = "${module.aws-iam.kube-worker-profile}"
#   key_name             = "${var.AWS_SSH_KEY_NAME}"

#   tags = "${merge(var.default_tags, map(
#       "Name", "kubernetes-${var.aws_cluster_name}-worker${count.index}",
#       "kubernetes.io/cluster/${var.aws_cluster_name}", "member",
#       "Role", "worker"
#     ))}"
# }


