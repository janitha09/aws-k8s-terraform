provider "aws" {
  region = "${var.aws["region"]}"
}

resource "aws_instance" "k8s_master" {
  # depends_on = ["aws_key_pair.cluster"]
  ami                    = var.aws_instance["ami"]
  count                  = var.aws_instance["count"]
  instance_type          = var.aws_instance["instance_type"]
  key_name               = var.aws_public_key
  vpc_security_group_ids = var.vpc_security_group_ids #["${aws_security_group.self.id}"]
  subnet_id              = var.subnet_id

  iam_instance_profile = "${aws_iam_instance_profile.janitha_k8s_master_profile.name}"

  root_block_device {
    volume_size = "30"
  }
  tags = {
    Name    = "${var.tag-environment}-k8s-HA-master-${count.index}"
    Team    = "${var.tag-environment}-team"
    Purpose = "${var.tag-environment}-play"
  }
}

# https://medium.com/@devopslearning/aws-iam-ec2-instance-role-using-terraform-fa2b21488536
resource "aws_iam_role" "janitha_k8s_master_role" {
  name = "${var.tag-environment}_k8s_master_role"

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
    Name = "${var.tag-environment}_k8s_master_role"
  }
}

resource "aws_iam_instance_profile" "janitha_k8s_master_profile" {
  name = "${var.tag-environment}_k8s_master_profile"
  role = "${aws_iam_role.janitha_k8s_master_role.name}"
}

resource "aws_iam_policy" "master_policy" {
  name = "${var.tag-environment}_k8s_master"
  path = "/"
  description = "k8s master policy https://github.com/kubernetes/cloud-provider-aws#readme"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVolumes",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyVolume",
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteVolume",
        "ec2:DetachVolume",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DescribeVpcs",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:AttachLoadBalancerToSubnets",
        "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateLoadBalancerPolicy",
        "elasticloadbalancing:CreateLoadBalancerListeners",
        "elasticloadbalancing:ConfigureHealthCheck",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancerListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DetachLoadBalancerFromSubnets",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancerPolicies",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
        "iam:CreateServiceLinkedRole",
        "kms:DescribeKey"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
  EOF
}

output "count" {
  value = var.aws_instance["count"]
}

output "id" {
  value = aws_instance.k8s_master.*.id
}

output "tags_name" {
  value = aws_instance.k8s_master.*.tags.Name
}

output "public_ip" {
  value = aws_instance.k8s_master.*.public_ip
}

output "private_ip" {
  value = aws_instance.k8s_master.*.private_ip
}

output "other_stuff" {
  value = {
    arn                    = aws_instance.k8s_master.*.arn
    availability_zone      = aws_instance.k8s_master.*.availability_zone
    subnet_id              = aws_instance.k8s_master.*.subnet_id
    security_groups        = aws_instance.k8s_master.*.vpc_security_group_ids
    vpc_security_group_ids = aws_instance.k8s_master.*.vpc_security_group_ids
    key_name               = aws_instance.k8s_master.*.key_name
    placement_group        = aws_instance.k8s_master.*.placement_group
  }
}

output "master_policy" {
  value = {
    id      = aws_iam_policy.master_policy.*.id
arn         = aws_iam_policy.master_policy.*.arn
description = aws_iam_policy.master_policy.*.description
name        = aws_iam_policy.master_policy.*.name
path        = aws_iam_policy.master_policy.*.path
policy      = aws_iam_policy.master_policy.*.policy
  }
}
