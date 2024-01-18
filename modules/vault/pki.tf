resource "vault_mount" "root" {
  path        = "pki"
  type        = "pki"
  description = "PKI for Consul Agent Root CA"

  default_lease_ttl_seconds = 315360000
  max_lease_ttl_seconds     = 315360000
}

resource "vault_mount" "intermediate" {
  path        = "pki_int"
  type        = "pki"
  description = "PKI for Consul Agent Intermediate CA"

  default_lease_ttl_seconds = 157680000
  max_lease_ttl_seconds     = 157680000
}

resource "vault_mount" "connect_root" {
  path        = "connect_root"
  type        = "pki"
  description = "PKI for Consul Connect Root CA"
}

resource "vault_mount" "connect_dc1_inter" {
  path        = "connect_dc1_inter"
  type        = "pki"
  description = "PKI for Consul Connect Intermediate Root CA"
}

resource "vault_pki_secret_backend_root_cert" "root" {
  depends_on           = [vault_mount.root]
  backend              = vault_mount.root.path
  type                 = "internal"
  common_name          = "Root CA"
  ttl                  = "315360000"
  format               = "pem"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "Demo OU"
  organization         = "Demo Organization"
}

resource "vault_pki_secret_backend_config_urls" "root" {
  depends_on              = [vault_pki_secret_backend_root_cert.root]
  backend                 = vault_mount.root.path
  issuing_certificates    = ["https://127.0.0.1:8200/v1/pki/ca"]
  crl_distribution_points = ["https://127.0.0.1:8200/v1/pki/crl"]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "consul" {
  depends_on  = [vault_mount.intermediate]
  backend     = vault_mount.intermediate.path
  type        = "internal"
  common_name = "Consul Intermediate CA"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "consul" {
  backend              = vault_mount.root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.consul.csr
  common_name          = "Consul Intermediate CA"
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
  backend     = vault_mount.intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.consul.certificate
}

resource "vault_pki_secret_backend_role" "consul_dc1" {
  depends_on       = [vault_pki_secret_backend_intermediate_set_signed.consul]
  backend          = vault_mount.intermediate.path
  name             = "consul-dc1"
  ttl              = 31536000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  generate_lease   = true
  allow_subdomains = true
  allowed_domains  = ["dc1.consul", "elb.amazonaws.com"]
  allowed_uri_sans = ["localhost", "${var.elb_http_addr}"]
}

resource "vault_pki_secret_backend_cert" "consul_server" {
  depends_on = [vault_pki_secret_backend_role.consul_dc1]

  backend = vault_mount.intermediate.path
  name    = vault_pki_secret_backend_role.consul_dc1.name

  common_name = "server.${var.consul_datacenter}.consul"
  ttl         = 31536000
  ip_sans     = ["127.0.0.1"]
  uri_sans    = ["localhost", "${var.elb_http_addr}"]
}
