apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: "external"
    cloud-config: "/etc/kubernetes/cloud.conf" # not sure this is used by aws anymore (IAM roles and policies bypass this) I am not mounting it see https://github.com/kubernetes/cloud-provider-openstack/blob/master/manifests/controller-manager/cloud-config
# https://medium.com/kokster/how-to-run-cloud-controller-manager-on-aws-using-kops-6a51f61a1ba2 - outdated cloud provider aws should be external
# https://kubernetes.io/docs/concepts/architecture/cloud-controller/
---
# https://blog.scottlowe.org/2018/09/28/setting-up-the-kubernetes-aws-cloud-provider/
apiVersion: kubeadm.k8s.io/v1beta2
kind: MasterConfiguration
apiServerExtraArgs:
  cloud-provider: external 
controllerManagerExtraArgs:
  cloud-provider: external
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: 1.15.1
controlPlaneEndpoint: ${HAPROXY_PRIVATE_IP}:6443 # shorter names works
networking:
  podSubnet: 192.168.0.0/16