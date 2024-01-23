resource "vault_mount" "root" {
  for_each    = var.consul_datacenters
  path        = "pki_${each.key}"
  type        = "pki"
  description = "PKI for Consul Agent Root CA - ${each.key}"

  default_lease_ttl_seconds = 315360000
  max_lease_ttl_seconds     = 315360000
}

resource "vault_mount" "intermediate" {
  for_each    = var.consul_datacenters
  path        = "pki_int_${each.key}"
  type        = "pki"
  description = "PKI for Consul Agent Intermediate CA - ${each.key}"

  default_lease_ttl_seconds = 157680000
  max_lease_ttl_seconds     = 157680000
}

resource "vault_mount" "connect_root" {
  for_each    = var.consul_datacenters
  path        = "connect_root_${each.key}"
  type        = "pki"
  description = "PKI for Consul Connect Root CA - ${each.key}"
}

resource "vault_mount" "connect_dc_inter" {
  for_each    = var.consul_datacenters
  path        = "connect_${each.key}_inter"
  type        = "pki"
  description = "PKI for Consul Connect Intermediate Root CA - ${each.key}"
}

resource "vault_pki_secret_backend_root_cert" "root" {
  for_each             = var.consul_datacenters
  backend              = vault_mount.root[each.key].path
  type                 = "internal"
  common_name          = "Root CA"
  ttl                  = "315360000"
  format               = "pem"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "Demo OU"
  organization         = "Demo Organization"
  depends_on           = [vault_mount.root]
}

resource "vault_pki_secret_backend_config_urls" "root" {
  for_each                = var.consul_datacenters
  backend                 = vault_mount.root[each.key].path
  issuing_certificates    = ["https://127.0.0.1:8200/v1/pki_${each.key}/ca"]
  crl_distribution_points = ["https://127.0.0.1:8200/v1/pki_${each.key}/crl"]
  depends_on              = [vault_pki_secret_backend_root_cert.root]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "consul" {
  for_each    = var.consul_datacenters
  backend     = vault_mount.intermediate[each.key].path
  type        = "internal"
  common_name = "Consul Intermediate CA - ${each.key}"
  depends_on  = [vault_mount.intermediate]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "consul" {
  for_each             = var.consul_datacenters
  backend              = vault_mount.root[each.key].path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.consul[each.key].csr
  common_name          = "Consul Intermediate CA - ${each.key}"
  exclude_cn_from_sans = true
  ou                   = "Demo OU"
  organization         = "Demo Organization"
  country              = "SG"
  locality             = "Singapore"
  province             = "SG"
  revoke               = true
  ttl                  = 157680000
}

resource "vault_pki_secret_backend_intermediate_set_signed" "consul" {
  for_each    = var.consul_datacenters
  backend     = vault_mount.intermediate[each.key].path
  certificate = vault_pki_secret_backend_root_sign_intermediate.consul[each.key].certificate
}

resource "vault_pki_secret_backend_role" "consul_dc" {
  for_each         = var.consul_datacenters
  backend          = vault_mount.intermediate[each.key].path
  name             = "consul-${each.key}"
  ttl              = 31536000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  generate_lease   = true
  allow_subdomains = true
  allowed_domains  = ["${each.key}.consul", "elb.amazonaws.com"]
  allowed_uri_sans = ["localhost", "${var.elb_http_addr}"]
  depends_on       = [vault_pki_secret_backend_intermediate_set_signed.consul]
}

resource "vault_pki_secret_backend_cert" "consul_server" {
  for_each = var.consul_datacenters
  backend  = vault_mount.intermediate[each.key].path
  name     = vault_pki_secret_backend_role.consul_dc[each.key].name

  common_name = "server.${each.key}.consul"
  ttl         = 31536000
  ip_sans     = ["127.0.0.1"]
  uri_sans    = ["localhost", "${var.elb_http_addr}"]
  depends_on  = [vault_pki_secret_backend_role.consul_dc]
}
