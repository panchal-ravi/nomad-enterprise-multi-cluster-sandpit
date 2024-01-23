/*
resource "local_file" "consul_server_key" {
    content = vault_pki_secret_backend_cert.consul_server.private_key
    filename = "${path.module}/tmp/consul_${var.consul_datacenter}.key"
}

resource "local_file" "consul_server_crt" {
    content = vault_pki_secret_backend_cert.consul_server.certificate
    filename = "${path.module}/tmp/consul_${var.consul_datacenter}.crt"
}

resource "local_file" "issuing_ca" {
    content = vault_pki_secret_backend_cert.consul_server.issuing_ca
    filename = "${path.module}/tmp/ca_${var.consul_datacenter}.crt"
}

resource "local_file" "root_ca" {
    content = vault_pki_secret_backend_root_cert.root.certificate
    filename = "${path.module}/tmp/root_${var.consul_datacenter}.crt"
}
*/