server = true
datacenter = "${datacenter}"
bootstrap_expect = ${server_count}
node_name = "consul-server-${index}"
retry_join = ["provider=aws tag_key=consul_datacenter tag_value=${datacenter}"]
bind_addr = "${private_ip}"
advertise_addr = "${private_ip}"
// client_addr = "${private_ip}"
client_addr = "0.0.0.0"
ui = true
license_path = "/etc/consul.d/license.hclic"

log_file = "/var/log/consul/"
log_level = "DEBUG"
encrypt = "${gossip_key}"
encrypt_verify_incoming = true
encrypt_verify_outgoing = true

tls {
  defaults {
    ca_file = "/etc/consul.d/tls/ca.crt"
    cert_file = "/etc/consul.d/tls/consul.crt"
    key_file = "/etc/consul.d/tls/consul.key"
    verify_outgoing = true
  }
  internal_rpc {
    verify_incoming = true
    verify_server_hostname = true
  }
  https {
    // verify_incoming = true // This would require client TLS private/public key to communicate with Server HTTPs
  }
}
ports {
  http = 8500
  https = 8501
}
auto_encrypt {
  allow_tls = true
}

node_meta {
  redundancy_zone = "${zone}"
}

autopilot {
  redundancy_zone_tag = "redundancy_zone"
}

connect {
  enabled = true
  ca_provider = "vault"
  ca_config {
    address = "https://${elb_http_addr}:8200"
    token = "${vault_connect_ca_token}"
    root_pki_path = "connect_root_${datacenter}"
    intermediate_pki_path = "connect_${datacenter}_inter"
    leaf_cert_ttl = "72h"
    rotation_period = "2160h"
    intermediate_cert_ttl = "8760h"
    private_key_type = "rsa"
    private_key_bits = 2048
    tls_skip_verify = "true"
  }
}