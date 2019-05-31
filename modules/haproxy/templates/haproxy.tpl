global
  debug
  log stdout format raw daemon


defaults
  log global
  mode tcp
  maxconn 5000

  timeout connect 5s
  timeout client  20s
  timeout server  20s

frontend frontend
  bind *:6443
  default_backend backend

backend backend
  server master0 ${MASTER_IP1}:6443 check