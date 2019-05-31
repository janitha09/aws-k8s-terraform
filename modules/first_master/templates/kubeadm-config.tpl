apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: 1.14.2
controlPlaneEndpoint: "${HAPROXY_IP}:6443" # shorter names works
# apiServer:
#  certSANs:
#  - "janitha-2ec89d38da1f97a7.elb.us-east-2.amazonaws.com"
networking:
  podSubnet: 192.168.0.0/16
# controllerManager:
#   extraArgs:
#     cluster-signing-cert-file: /etc/kubernetes/pki_LB/ca.crt
#     cluster-signing-key-file: /etc/kubernetes/pki_LB/ca.key
#     jibberish: "jibberish"
    # tls-private-key-file: /etc/kubernetes/pki_LB/apiserver.key
    # tls-cert-file: /etc/kubernetes/pki_LB/apiserver.crt
    # https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta1
# ---
# apiVersion: kubeadm.k8s.io/v1beta1
# kind: InitConfiguration
# localAPIEndpoint:
#   advertiseAddress: "0.0.0.0"