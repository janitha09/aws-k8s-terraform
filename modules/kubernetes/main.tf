resource "null_resource" "kubernetes_execute" {
  # depends_on = ["null_resource.kubernetes"]

  count = "${var.instances}"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/janitha.jayaweera.pem")}" #${file("${path.module}/janitha.jayaweera.pem")}
    host        = "${element(var.public_ip, count.index)}"
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
      "sudo apt-get update && apt-get install -y apt-transport-https curl",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "sudo bash -c 'cat > /etc/apt/sources.list.d/kubernetes.list <<EOF",
      "deb https://apt.kubernetes.io/ kubernetes-xenial main",
      "EOF'",
      "sudo cat /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update",
      "sudo apt-get install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl"
    ]
  }
}
