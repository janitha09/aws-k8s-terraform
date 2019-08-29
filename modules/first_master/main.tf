
resource "null_resource" "dummyvar" {
  provisioner "local-exec" {
    command = "echo ${var.kubernetes_installed_on_master_atleast}"
  }
}

resource "null_resource" "kubeadm-config" {
  depends_on = ["null_resource.dummyvar"]
  # triggers = {
  #   cluster_instance_ids = "${join(",", var.master_private_ip)}"
  # }

  count = 1
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, count.index)}"
  }

  provisioner "file" {
    content     = "${element(data.template_file.kubeadm-config.*.rendered, 0)}"
    destination = "/home/ubuntu/kubeadm-config.yaml"
  }
}
resource "null_resource" "kubeadm-init" {
  depends_on = ["null_resource.kubeadm-config"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  # https://github.com/stillinbeta/srecon-k8s-tutorial/blob/46152b4f1c184f07d49f25a81b780950aebb4822/tutorial1.md
  provisioner "remote-exec" {
    inline = [
      # "sudo cp -r /etc/kubernetes/pki_LB/* /etc/kubernetes/pki/",
      "sudo kubeadm init --config /home/ubuntu/kubeadm-config.yaml --experimental-upload-certs --v 10 " #--pod-network-cidr=192.168.0.0/16"
      # "sudo kubeadm reset --force --v 10",
      # "sudo kubeadm init phase preflight --config /home/ubuntu/kubeadm-config.yaml --v 10",
      # "sudo kubeadm init phase certs all --config ~/kubeadm-config.yaml --v 10",
      # "sudo cp -r /etc/kubernetes/pki_LB/* /etc/kubernetes/pki/", # preserve certs on the LB
      # "sudo kubeadm init phase kubeconfig all --config /home/ubuntu/kubeadm-config.yaml",
      # "sudo kubeadm init phase kubelet-start --config ~/kubeadm-config.yaml --v 10", # does n't really start Failed to list *v1.Node: the server is currently unable to handle the request (get nodes)
      # "sudo kubeadm init phase control-plane all --config ~/kubeadm-config.yaml --v 10",
      # "sudo kubeadm init phase etcd local --config ~/kubeadm-config.yaml --v 10",
      # "sudo kubeadm init phase kubelet-start --config ~/kubeadm-config.yaml --v 10", # update docs to say run this later? https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init-phase/#cmd-phase-upload-certs
      # "sudo kubeadm init phase upload-certs --config ~/kubeadm-config.yaml --experimental-upload-certs --v 10", # this does not work
      # "sudo kubeadm init phase mark-control-plane --config ~/kubeadm-config.yaml --v 10", # cannot get to the node kubectl is trying to connect to localhost
      # "sudo kubeadm init phase bootstrap-token --config ~/kubeadm-config.yaml --v 10", #this fails because of secrets
      # "sudo kubeadm init phase upload-config all --config ~/kubeadm-config.yaml --v 10",
      # "sudo kubeadm init phase addon all --config ~/kubeadm-config.yaml --v 10" # --pod-network-cidr 192.168.0.0/16
    ]
  }
  # provisioner "remote-exec" {
  #   inline = [
  #     "mkdir -p $HOME/.kube",
  #     "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
  #     "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
  #   ]
  # }
  # provisioner "remote-exec" {
  #   when = "destroy"
  #   inline = [
  #     "sudo kubeadm reset --force --v 10",
  #   ]
  # }
}

resource "null_resource" "install-calico" {
  depends_on = ["null_resource.kubeadm-init"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f https://docs.projectcalico.org/${var.calico-version}/manifests/calico.yaml",
      "sudo ip route",
      "sudo iptables -L"
    ]
  }
}

resource "null_resource" "install-helm" {
  depends_on = ["null_resource.install-calico"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -L https://git.io/get_helm.sh | bash"
    ]
  }
}

resource "null_resource" "setup_kubectl_to_run_under_user" {
  depends_on = ["null_resource.install-helm"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown -R $(id -u):$(id -g) $HOME/.kube"
    ]
  }
  # provisioner "remote-exec" {
  #   when = "destroy"
  #   inline = [
  #     "sudo rm -rf $HOME/.kube"
  #   ]
  # }
}
resource "null_resource" "install-istio" {
  depends_on = ["null_resource.setup_kubectl_to_run_under_user"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -L https://git.io/getLatestIstio | ISTIO_VERSION=${var.istio-version} sh -",
      "kubectl create namespace istio-system",
      "helm template ~/istio-${var.istio-version}/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -",
      "sleep 10",
      "helm template ~/istio-${var.istio-version}/install/kubernetes/helm/istio --name istio --namespace istio-system --values ~/istio-${var.istio-version}/install/kubernetes/helm/istio/values-istio-demo-auth.yaml | kubectl apply -f -",
      "exit 0" #hack for istio crds taking too long
      # "sudo kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f ~/istio-1.1.7/install/kubernetes/helm/helm-service-account.yaml",
      # "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E helm init --service-account tiller",
      # "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E helm install ~/istio-1.1.7/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system",
      # "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E helm install ~/istio-1.1.7/install/kubernetes/helm/istio --name istio --namespace istio-system --values ~/istio-1.1.7/install/kubernetes/helm/istio/values-istio-demo.yaml"
    ]
  }
}

resource "null_resource" "install-istio-again" {
  depends_on = ["null_resource.install-istio"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      # "curl -L https://git.io/getLatestIstio | ISTIO_VERSION=${var.istio-version} sh -",
      # "kubectl create namespace istio-system",
      # "helm template ~/istio-${var.istio-version}/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -",
      # "sleep 10",
      "helm template ~/istio-${var.istio-version}/install/kubernetes/helm/istio --name istio --namespace istio-system --values ~/istio-${var.istio-version}/install/kubernetes/helm/istio/values-istio-demo-auth.yaml | kubectl apply -f -",
      "exit 0" #hack for istio crds taking too long
      # "sudo kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f ~/istio-1.1.7/install/kubernetes/helm/helm-service-account.yaml",
      # "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E helm init --service-account tiller",
      # "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E helm install ~/istio-1.1.7/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system",
      # "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E helm install ~/istio-1.1.7/install/kubernetes/helm/istio --name istio --namespace istio-system --values ~/istio-1.1.7/install/kubernetes/helm/istio/values-istio-demo.yaml"
    ]
  }
}

resource "null_resource" "rbac_for_tiller" {
  depends_on = ["null_resource.install-istio"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      # "curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.7 sh -",
      # "kubectl create namespace istio-system",
      # "helm template ~/istio-1.1.7/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -",
      # "helm template ~/istio-1.1.7/install/kubernetes/helm/istio --name istio --namespace istio-system --values ~/istio-1.1.7/install/kubernetes/helm/istio/values-istio-demo-auth.yaml | kubectl apply -f -",
      "sudo kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f ~/istio-${var.istio-version}/install/kubernetes/helm/helm-service-account.yaml",
      # "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E" 
      "helm init --service-account tiller"
      # "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E helm install ~/istio-1.1.7/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system",
      # "KUBECONFIG=/etc/kubernetes/admin.conf sudo -E helm install ~/istio-1.1.7/install/kubernetes/helm/istio --name istio --namespace istio-system --values ~/istio-1.1.7/install/kubernetes/helm/istio/values-istio-demo.yaml"
    ]
  }
}

resource "null_resource" "install-elasticsearchkibana" {
  depends_on = ["null_resource.setup_kubectl_to_run_under_user"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOS
cat <<EOF | kubectl apply -f -
# Logging Namespace. All below are a part of this namespace.
apiVersion: v1
kind: Namespace
metadata:
  name: logging
---
# Elasticsearch Service
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: logging
  labels:
    app: elasticsearch
spec:
  ports:
  - port: 9200
    protocol: TCP
    targetPort: db
  selector:
    app: elasticsearch
---
# Elasticsearch Deployment
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: elasticsearch
  namespace: logging
  labels:
    app: elasticsearch
spec:
  template:
    metadata:
      labels:
        app: elasticsearch
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      containers:
      - image: docker.elastic.co/elasticsearch/elasticsearch-oss:6.1.1
        name: elasticsearch
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
            memory: "2Gi"
          requests:
            cpu: 100m
            memory: "2Gi"
        env:
          - name: discovery.type
            value: single-node
        ports:
        - containerPort: 9200
          name: db
          protocol: TCP
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - name: elasticsearch
          mountPath: /data
      volumes:
      - name: elasticsearch
        emptyDir: {}
---
# Kibana Service
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: logging
  labels:
    app: kibana
spec:
  ports:
  - port: 5601
    protocol: TCP
    targetPort: ui
  selector:
    app: kibana
---
# Kibana Deployment
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: kibana
  namespace: logging
  labels:
    app: kibana
spec:
  template:
    metadata:
      labels:
        app: kibana
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      containers:
      - name: kibana
        image: docker.elastic.co/kibana/kibana-oss:6.1.1
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
        env:
          - name: ELASTICSEARCH_URL
            value: http://elasticsearch:9200
        ports:
        - containerPort: 5601
          name: ui
          protocol: TCP
---
EOF
      EOS
    ]
  }
}
resource "null_resource" "install-fluentd" {
  depends_on = ["null_resource.setup_kubectl_to_run_under_user"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOS
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentd
  namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: fluentd
  namespace: kube-system
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - namespaces
  verbs:
  - get
  - list
  - watch

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: fluentd
roleRef:
  kind: ClusterRole
  name: fluentd
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: fluentd
  namespace: kube-system
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
    version: v1
spec:
  template:
    metadata:
      labels:
        k8s-app: fluentd-logging
        version: v1
    spec:
      serviceAccount: fluentd
      serviceAccountName: fluentd
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:elasticsearch
        env:
          - name:  FLUENT_ELASTICSEARCH_HOST
            value: "elasticsearch.logging.svc.cluster.local"
          - name:  FLUENT_ELASTICSEARCH_PORT
            value: "9200"
          - name: FLUENT_ELASTICSEARCH_SCHEME
            value: "http"
          - name: FLUENT_UID
            value: "0"
          # X-Pack Authentication
          # =====================
          #- name: FLUENT_ELASTICSEARCH_USER
          #  value: "elastic"
          #- name: FLUENT_ELASTICSEARCH_PASSWORD
          #  value: "changeme"
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
EOF
      EOS
    ]
  }
}

resource "null_resource" "metrics-server" {
  depends_on = ["null_resource.setup_kubectl_to_run_under_user"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOS
cat <<EOF | kubectl apply -f -
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: system:aggregated-metrics-reader
  labels:
    rbac.authorization.k8s.io/aggregate-to-view: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
rules:
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-server
  namespace: kube-system
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    k8s-app: metrics-server
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    metadata:
      name: metrics-server
      labels:
        k8s-app: metrics-server
    spec:
      serviceAccountName: metrics-server
      volumes:
      # mount in tmp so we can safely use from-scratch images and/or read-only containers
      - name: tmp-dir
        emptyDir: {}
      containers:
      - name: metrics-server
        image: k8s.gcr.io/metrics-server-amd64:v0.3.3
        imagePullPolicy: Always
        args:
        - --logtostderr
        - --v=1
        - --kubelet-insecure-tls
        - --kubelet-preferred-address-types=InternalIP
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp      
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  - nodes/stats
  - namespaces
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system 
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system    
---
apiVersion: apiregistration.k8s.io/v1beta1
kind: APIService
metadata:
  name: v1beta1.metrics.k8s.io
spec:
  service:
    name: metrics-server
    namespace: kube-system
  group: metrics.k8s.io
  version: v1beta1
  insecureSkipTLSVerify: true
  groupPriorityMinimum: 100
  versionPriority: 100
---
apiVersion: v1
kind: Service
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    kubernetes.io/name: "Metrics-server"
    kubernetes.io/cluster-service: "true"
spec:
  selector:
    k8s-app: metrics-server
  ports:
  - port: 443
    protocol: TCP
    targetPort: 443                                   
EOF
      EOS
    ]
  }
}

## This only works on prem IP address range is exposed via the config map
resource "null_resource" "install-metallb" {
  depends_on = ["null_resource.setup_kubectl_to_run_under_user"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.root}/${var.aws_public_key}.pem")}"
    host        = "${element(var.master_private_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOS
kubectl create namespace metallb-system
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.1.240-192.168.1.250
---
EOF
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml        
      EOS
    ]
  }
}

output "k8s_installed_on_first_master" {
  value = null_resource.rbac_for_tiller.id
}


# resource "null_resource" "master_join_token" {
#   depends_on = ["null_resource.run-kubeadm"]
#   provisioner "local-exec" {
#     command = 
#   }
# }
# You can now join any number of the control-plane node running the following command on each as root:

# kubeadm join 172.31.16.155:6443 --token jke2ys.lf9okzcpfx4aoi55 \
# --discovery-token-ca-cert-hash sha256:32d3b0b88bdb6e8d567b60303a9093201cd4bca0ee57d3d8cbe108c8cb4203fd \
# --experimental-control-plane --certificate-key b2f9f17044d8ef49397816213e994993cfd74419c9d5bb5d72d6f0e98aa600c6

# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): "kubeadm init phase upload-certs --experimental-upload-certs" to reload certs afterward.

# module.kubernetes_first_master.null_resource.run-kubeadm (remote-exec): Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join 172.31.16.155:6443 --token jke2ys.lf9okzcpfx4aoi55 \
# --discovery-token-ca-cert-hash sha256:32d3b0b88bdb6e8d567b60303a9093201cd4bca0ee57d3d8cbe108c8cb4203fd







data "template_file" "kubeadm-config" {
  template = "${file("${path.module}/templates/kubeadm-config.tpl")}"

  vars = {
    HAPROXY_PRIVATE_IP = "${element(var.haproxy_private_ip, 0)}"
  }
}
