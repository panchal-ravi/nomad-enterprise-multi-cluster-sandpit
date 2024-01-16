resource "tls_private_key" "ca_private_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_private_key.private_key_pem

  is_ca_certificate = true

  subject {
    country             = "SG"
    province            = "Singapore"
    locality            = "Singapore"
    common_name         = "Demo Root CA"
    organization        = "Demo Organization"
    organizational_unit = "Demo Organization Root Certification Authority"
  }

  validity_period_hours = 43800 //  1825 days or 5 years

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

/*
resource "local_file" "ca_private_key" {
  content  = tls_private_key.ca_private_key.private_key_pem
  filename = "${path.module}/tmp/ca.key"
}

resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.ca_cert.cert_pem
  filename = "${path.module}/tmp/ca.cert"
}

resource "local_file" "vault_server_cert" {
  content  = tls_locally_signed_cert.vault_server_signed_cert.cert_pem
  filename = "${path.module}/tmp/vault_server.cert"
}

resource "local_file" "vault_server_private_key" {
  content  = tls_private_key.vault_server_private_key.private_key_pem
  filename = "${path.module}/tmp/vault_server.key"
}
*/

# Create private key for vault server certificate 
resource "tls_private_key" "vault_server_private_key" {
  algorithm = "RSA"
}

# Create CSR for for vault server certificate 
resource "tls_cert_request" "vault_server_csr" {

  private_key_pem = tls_private_key.vault_server_private_key.private_key_pem

  dns_names = ["demo.server.vault",  "localhost", "${aws_lb.http_lb.dns_name}"]
  ip_addresses = ["127.0.0.1"]

  subject {
    country             = "SG"
    province            = "Singapore"
    locality            = "Singapore"
    common_name         = "demo.server.vault"
    organization        = "Demo Organization"
    organizational_unit = "Development"
  }
}

# Sign Server Certificate by Private CA 
resource "tls_locally_signed_cert" "vault_server_signed_cert" {
  // CSR by the vault servers
  cert_request_pem = tls_cert_request.vault_server_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = tls_private_key.ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 43800

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}
