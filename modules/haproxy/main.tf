############################
########### AWS ############
############################

provider "aws" {
  # access_key = "${var.aws["access_key"]}"
  # secret_key = "${var.aws["secret_key"]}"
  region = "${var.aws["region"]}"
}

# resource "aws_key_pair" "cluster" {
#   key_name   = "${var.key["name"]}"
#   # public_key = "${var.public_key}"
# }

resource "aws_instance" "haproxy" {
  # depends_on = ["aws_key_pair.cluster"]
  ami             = "${var.aws_instance["ami"]}"
  count           = var.aws_instance["count"]
  instance_type   = var.aws_instance["instance_type"]
  key_name        = var.aws_ec2_private_key
  security_groups = var.security_groups
  root_block_device {
    volume_size = "30"
  }
  tags = {
    Name    = "janitha-k8s-HAPROXY-${count.index}"
    Team    = "janitha-HAPROXY"
    Purpose = "janitha-HAPROXY"
  }
}

resource "null_resource" "haproxy_execute" {
  depends_on = ["aws_instance.haproxy"]

  count = var.aws_instance["count"]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.module}/janitha.jayaweera.pem")}" #${file("${path.module}/janitha.jayaweera.pem")}
    host        = "${element(aws_instance.haproxy.*.public_ip, count.index)}"
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
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "git clone https://github.com/janitha09/docker-haproxy-nginx.git",
      "cd /docker-haproxy-nginx",
      "git checkout sslpassthrough"
      "docker-compose up -d"
      # "sudo apt-get update && apt-get install -y apt-transport-https curl",
      # "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      # "sudo bash -c 'cat > /etc/apt/sources.list.d/kubernetes.list <<EOF",
      # "deb https://apt.kubernetes.io/ kubernetes-xenial main",
      # "EOF'",
      # "sudo cat /etc/apt/sources.list.d/kubernetes.list",
      # "sudo apt-get update",
      # "sudo apt-get install -y kubelet kubeadm kubectl",
      # "sudo apt-mark hold kubelet kubeadm kubectl"
    ]
  }
}


############################
######### POST AWS #########
############################

#resource "aws_eip_association" "proxy_eip" {
#  depends_on = ["null_resource.etcd_execute", "null_resource.master-post"]
#  instance_id   = "${aws_instance.cluster.0.id}"
#  allocation_id = "${data.aws_eip.proxy_ip.id}"
#}

############################
########## OUTPUT ##########
############################

output "count" {
  value = var.aws_instance["count"]
}

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

