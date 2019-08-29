global
  debug
  log stdout format raw daemon


defaults
  log global
  mode tcp
  maxconn 5000

  timeout connect 30s
  timeout client  300s
  timeout server  300s

frontend frontend
  bind *:6443
  default_backend backend

backend backend
  server master0 ${MASTER_PRIVATE_IP0}:6443 check
  server master1 ${MASTER_PRIVATE_IP1}:6443 check
  server master2 ${MASTER_PRIVATE_IP2}:6443 check