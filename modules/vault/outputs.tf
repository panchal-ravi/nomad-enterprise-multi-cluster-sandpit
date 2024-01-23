/*
output "consul_server_key" {
  # value = vault_pki_secret_backend_cert.consul_server.private_key
  value = {
    for k in var.consul_datacenters : k => vault_pki_secret_backend_cert.consul_server[k].private_key
  }
}

output "consul_server_crt" {
  # value = vault_pki_secret_backend_cert.consul_server.certificate
  value = {
    for k in var.consul_datacenters : k => vault_pki_secret_backend_cert.consul_server[k].certificate
  }
}

output "intermediate_ca" {
  # value = vault_pki_secret_backend_cert.consul_server.issuing_ca
  value = {
    for k in var.consul_datacenters : k => vault_pki_secret_backend_cert.consul_server[k].issuing_ca
  }
}

output "root_ca" {
  # value = vault_pki_secret_backend_root_cert.root.certificate
  value = {
    for k in var.consul_datacenters : k => vault_pki_secret_backend_root_cert.root[k].certificate
  }
}

output "vault_connect_ca_polcy" {
  # value = vault_policy.connect_ca.name
  value = {
    for k in var.consul_datacenters : k => vault_policy.connect_ca[k].name
  }
}
*/

output "this" {
  value = tomap({
    for k in var.consul_datacenters : k => {
      consul_server_key      = vault_pki_secret_backend_cert.consul_server[k].private_key
      consul_server_crt      = vault_pki_secret_backend_cert.consul_server[k].certificate
      intermediate_ca        = vault_pki_secret_backend_cert.consul_server[k].issuing_ca
      root_ca                = vault_pki_secret_backend_root_cert.root[k].certificate
      vault_connect_ca_polcy = vault_policy.connect_ca[k].name

    }
  })
}
