output "consul_server_key" {
  value = vault_pki_secret_backend_cert.consul_server.private_key
}

output "consul_server_crt" {
  value = vault_pki_secret_backend_cert.consul_server.certificate
}

output "intermediate_ca" {
  value = vault_pki_secret_backend_cert.consul_server.issuing_ca
}

output "root_ca" {
  value = vault_pki_secret_backend_root_cert.root.certificate
}

output "vault_connect_ca_polcy" {
  value = vault_policy.connect_ca.name
}
