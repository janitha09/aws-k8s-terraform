provider "aws" {
  region = "${var.aws["region"]}"
}

resource "aws_instance" "haproxy" {
  # depends_on = ["aws_key_pair.cluster"]
  ami                    = var.aws_instance["ami"]
  instance_type          = var.aws_instance["instance_type"]
  key_name               = var.aws_public_key
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id
  root_block_device {
    volume_size = "30"
  }
  tags = {
    Name    = "${var.tag-environment}-k8s-HAPROXY-${element(var.k8s_master_private_ips, 0)}-${element(var.k8s_master_private_ips, 1)}-${element(var.k8s_master_private_ips, 2)}"
    Team    = "${var.tag-environment}-team"
    Purpose = "${var.tag-environment}-play"
  }
}

resource "null_resource" "haproxy_install_docker" {
  depends_on = ["aws_instance.haproxy"]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}" #${file("${path.module}/${var.aws_public_key}")}
    host        = "${element(aws_instance.haproxy.*.private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get remove docker docker-engine docker.io containerd runc",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo bash -c 'cat > /etc/docker/daemon.json <<EOF",
      "{",
      "\"exec-opts\": [\"native.cgroupdriver=systemd\"],",
      "\"log-driver\": \"json-file\",",
      "\"log-opts\": {",
      "\"max-size\": \"100m\"",
      "},",
      "\"storage-driver\": \"overlay2\"",
      "}",
      "EOF'",
      "cat /etc/docker/daemon.json",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart docker",
      "sudo docker info",
      "sudo usermod -aG docker $USER", #sudo groupadd docker
    ]
  }
}

data "template_file" "haproxy-cfg" {
  template = "${file("${path.module}/templates/haproxy.tpl")}"

  vars = {
    MASTER_PRIVATE_IP0 = "${element(var.k8s_master_private_ips, 0)}"
    MASTER_PRIVATE_IP1 = "${element(var.k8s_master_private_ips, 1)}"
    MASTER_PRIVATE_IP2 = "${element(var.k8s_master_private_ips, 2)}"
  }
}

resource "null_resource" "create_haproxy_cfg" {
  depends_on = ["null_resource.haproxy_install_docker"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(aws_instance.haproxy.*.private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/haproxy"
    ]
  }

  provisioner "file" {
    content     = "${element(data.template_file.haproxy-cfg.*.rendered, 1)}"
    destination = "/home/ubuntu/haproxy/haproxy.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "bash -c 'cat > /home/ubuntu/haproxy/Dockerfile << EOF",
      "FROM haproxy:latest",
      "COPY ./haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg",
      "EOF'",
      "docker build -t haproxy_master_lb:latest /home/ubuntu/haproxy",
      "docker run -d -p 6443:6443 --restart always --name ${element(var.k8s_master_private_ips, 0)} haproxy_master_lb:latest"
    ]
  }
}

# output "count" {
#   value = aws_instance.haproxy.*.count
# }
output "id" {
  value = aws_instance.haproxy.*.id
}

output "tags_name" {
  value = aws_instance.haproxy.*.tags.Name
}

output "public_ip" {
  value = aws_instance.haproxy.*.public_ip
}

output "private_ip" {
  value = aws_instance.haproxy.*.private_ip
}

output "other_stuff" {
  value = {
    arn                    = aws_instance.haproxy.*.arn
    availability_zone      = aws_instance.haproxy.*.availability_zone
    subnet_id              = aws_instance.haproxy.*.subnet_id
    security_groups        = aws_instance.haproxy.*.vpc_security_group_ids
    vpc_security_group_ids = aws_instance.haproxy.*.vpc_security_group_ids
    key_name               = aws_instance.haproxy.*.key_name
    placement_group        = aws_instance.haproxy.*.placement_group
  }
}

