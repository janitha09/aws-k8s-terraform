apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: 1.14.2
controlPlaneEndpoint: ${HAPROXY_PRIVATE_IP}:6443 # shorter names works
networking:
  podSubnet: 192.168.0.0/16