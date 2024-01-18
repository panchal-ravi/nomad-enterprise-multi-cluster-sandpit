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
  value = module.infra_aws.bastion_ip
}

output "nomad_http_addr" {
  value = "https://${module.infra_aws.elb_http_addr}:8080"
}

output "consul_http_addr" {
  value = "https://${module.infra_aws.elb_http_addr}:8501"
}

output "vault_http_addr" {
  value = "https://${module.infra_aws.elb_http_addr}:8200"
}

output "vault_token" {
  value = module.infra_aws.vault_token
}

output "consul_management_token" {
  value = module.consul.consul_management_token
}

output "consul_client_ips" {
  value = module.consul.consul_client_ips
}

output "consul_server_ips" {
  value = module.consul.consul_server_ips
}

output "vault_ip" {
  value = module.infra_aws.vault_ip
}

