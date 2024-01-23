
output "nomad_cluster1" {
  value = {
    server_ips = module.nomad_cluster1.nomad_server_ips,
    client_ips = module.nomad_cluster1.nomad_client_ips,
  }
}

output "nomad_cluster2" {
  value = {
    server_ips = module.nomad_cluster2.nomad_server_ips,
    client_ips = module.nomad_cluster2.nomad_client_ips,
  }
}


output "bastion_ip" {
  value = module.infra_aws.this.bastion_ip
}

output "nomad_http_addr" {
  value = "https://${module.infra_aws.this.elb_http_addr}:8080"
}

output "consul_http_addr" {
  value = "https://${module.infra_aws.this.elb_http_addr}:8501"
}

output "vault_http_addr" {
  value = "https://${module.infra_aws.this.elb_http_addr}:8200"
}

output "vault_token" {
  value = module.infra_aws.this.vault_token
}

output "consul_cluster1" {
  value = {
    server_ips       = module.consul_cluster1.consul_server_ips,
    client_ips       = module.consul_cluster1.consul_client_ips,
    management_token = module.consul_cluster1.consul_management_token
  }
}

output "consul_cluster2" {
  value = {
    server_ips       = module.consul_cluster2.consul_server_ips,
    client_ips       = module.consul_cluster2.consul_client_ips,
    management_token = module.consul_cluster2.consul_management_token
  }
}

output "vault_ip" {
  value = module.infra_aws.this.vault_ip
}

