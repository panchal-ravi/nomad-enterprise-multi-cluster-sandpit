/*
resource "tls_private_key" "ca_private_key" {
  algorithm = "RSA"
}

resource "local_file" "ca_private_key" {
  content  = tls_private_key.ca_private_key.private_key_pem
  filename = "${path.module}/tmp/ca.key"
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

resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.ca_cert.cert_pem
  filename = "${path.module}/tmp/ca.cert"
}
*/

# Create private key for nomad server certificate 
resource "tls_private_key" "nomad_server_private_key" {
  algorithm = "RSA"
}

# Create CSR for for nomad server certificate 
resource "tls_cert_request" "nomad_server_csr" {

  private_key_pem = tls_private_key.nomad_server_private_key.private_key_pem

  dns_names    = ["server.${var.nomad_region}.nomad", "localhost", "${var.infra_aws.elb_http_addr}"]
  ip_addresses = ["127.0.0.1"]

  subject {
    country             = "SG"
    province            = "Singapore"
    locality            = "Singapore"
    common_name         = "server.${var.nomad_region}.nomad"
    organization        = "Demo Organization"
    organizational_unit = "Development"
  }
}

# Sign Server Certificate by Private CA 
resource "tls_locally_signed_cert" "nomad_server_signed_cert" {
  // CSR by the nomad servers
  cert_request_pem = tls_cert_request.nomad_server_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = var.infra_aws.ca_key //tls_private_key.ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = var.infra_aws.ca_cert //tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 43800

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

/*
resource "local_file" "nomad_server_private_key" {
  content  = tls_private_key.nomad_server_private_key.private_key_pem
  filename = "${path.module}/tmp/nomad_server.key"
}

resource "local_file" "nomad_server_cert" {
  content  = tls_locally_signed_cert.nomad_server_signed_cert.cert_pem
  filename = "${path.module}/tmp/nomad_server.cert"
}
*/

// Nomad Client Certificate
resource "tls_private_key" "nomad_client_private_key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "nomad_client_csr" {

  private_key_pem = tls_private_key.nomad_client_private_key.private_key_pem

  dns_names    = ["nomad.demo.com", "client.${var.nomad_region}.nomad", "localhost"]
  ip_addresses = ["127.0.0.1"]

  subject {
    country             = "SG"
    province            = "Singapore"
    locality            = "Singapore"
    common_name         = "client.${var.nomad_region}.nomad"
    organization        = "Demo Organization"
    organizational_unit = "Development"
  }
}

# Sign Client Certificate by Private CA 
resource "tls_locally_signed_cert" "nomad_client_signed_cert" {
  // CSR by the nomad client
  cert_request_pem = tls_cert_request.nomad_client_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = var.infra_aws.ca_key //tls_private_key.ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = var.infra_aws.ca_cert //tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 43800

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

/*
resource "local_file" "nomad_client_private_key" {
  content  = tls_private_key.nomad_client_private_key.private_key_pem
  filename = "${path.module}/tmp/nomad_client.key"
}

resource "local_file" "nomad_client_cert" {
  content  = tls_locally_signed_cert.nomad_client_signed_cert.cert_pem
  filename = "${path.module}/tmp/nomad_client.cert"
}
*/

// Nomad CLI Certificate
resource "tls_private_key" "nomad_cli_private_key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "nomad_cli_csr" {

  private_key_pem = tls_private_key.nomad_cli_private_key.private_key_pem

  dns_names    = ["cli.${var.nomad_region}.nomad", "localhost"]
  ip_addresses = ["127.0.0.1"]

  subject {
    country             = "SG"
    province            = "Singapore"
    locality            = "Singapore"
    common_name         = "cli.${var.nomad_region}.nomad"
    organization        = "Demo Organization"
    organizational_unit = "Development"
  }
}

# Sign CLI Certificate by Private CA 
resource "tls_locally_signed_cert" "nomad_cli_signed_cert" {
  // CSR by the nomad cli
  cert_request_pem = tls_cert_request.nomad_cli_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = var.infra_aws.ca_key //tls_private_key.ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = var.infra_aws.ca_cert //tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 43800

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}
/*
resource "local_file" "nomad_cli_private_key" {
  content  = tls_private_key.nomad_cli_private_key.private_key_pem
  filename = "${path.module}/tmp/nomad_cli.key"
}

resource "local_file" "nomad_cli_cert" {
  content  = tls_locally_signed_cert.nomad_cli_signed_cert.cert_pem
  filename = "${path.module}/tmp/nomad_cli.cert"
}
*/