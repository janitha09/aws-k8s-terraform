# Terraform for AWS service

Terraform code for K8S cluster on AWS

## Getting Started

Three master k8s nodes and slave nodes are set up with this terraform HCL code.

### Prerequisite

1. Terraform
2. AWS access key & secret key
3. AWS Key Pair (Public & Private Key)

### Terraform Installation

Download: [Terraform](https://www.terraform.io/downloads.html)

```
curl -O https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
unzip terraform_0.11.10_linux_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin
```

### AWS access key & secret key

AWS Keys: [AWS Security Credential](https://console.aws.amazon.com/iam/home?#/security_credential)
AWS Region: [AWS Region](https://docs.aws.amazon.com/general/latest/gr/rande.html)

Fill below and name it as "module/masters/credential.tf"
```
variable "aws" {
  type    = "map"
  default = {
    access_key = ""
    secret_key = ""
    region     = ""
  }
}
```

### AWS Key Pair

Place your private key and public key into "module/masters/" as "id_rsa" and "id_rsa.pub" repectively.

## Terraform

### AWS Cluster Setup
Simple type below

```
terraform init
terraform apply
```

### Destroy
```
terraform destroy
```

## Kubernetes Cluster

Accesing K8S Master node with ssh

```
ssh -i module/masters/certs/id_rsa ubuntu@PUBLIC_IP
```

### ETCD

#### Checking etcd status
```
ubuntu@master0:~$ etcdctl cluster-health
member e0729dabcb149ee is healthy: got healthy result from http://1.1.1.1:2379
member 63128dce64240d6f is healthy: got healthy result from http://2.2.2.2:2379
member fc4e46dfa36f76cc is healthy: got healthy result from http://3.3.3.3:2379
cluster is healthy

```
