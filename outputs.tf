output "master" {
  value = {
    master_count      = module.masters.count
    master_id         = module.masters.id
    master_public_ip  = module.masters.public_ip
    master_private_ip = module.masters.private_ip
    master_tags_name  = module.masters.tags_name
  }
}

output "node" {
  value = {
    node_count      = module.nodes.count
    node_id         = module.nodes.id
    node_public_ip  = module.nodes.public_ip
    node_private_ip = module.nodes.private_ip
    node_tags_name  = module.nodes.tags_name
  }
}

output "load_balancer" {
  value = {
    instance = module.classic_load_balancer.instances
    dns_name = module.classic_load_balancer.dns_name
    port     = module.classic_load_balancer.listener_0
  }
}

