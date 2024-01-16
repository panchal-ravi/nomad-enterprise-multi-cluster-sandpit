server = false
datacenter = "${datacenter}"
node_name = "${node_name}"
retry_join = [
  "provider=aws tag_key=consul_datacenter tag_value=${datacenter}"
]
bind_addr = "${private_ip}"
advertise_addr = "${private_ip}"
// client_addr = "${private_ip}"
client_addr = "0.0.0.0"

// license_path = "/etc/consul.d/license.hclic"

log_file = "/var/log/consul/"
log_level = "DEBUG"
encrypt = "${gossip_key}"
encrypt_verify_incoming = true
encrypt_verify_outgoing = true

tls {
  defaults {
    ca_file = "/etc/consul.d/tls/ca.crt"
    verify_outgoing = true
  }
  internal_rpc {
    // verify_incoming = true // Not applicable for client agents
    verify_server_hostname = true
  }
  https {
    // verify_incoming = true // This would require client TLS private/public key to communicate with Server HTTPs
  }
  grpc {
    // use_auto_cert = true // Comment this if Consul > 1.13
  }
}
auto_encrypt {
  tls = true
}
ports {
  http = 8500
  https = 8501
  // grpc = 8502 // Uncomment this if Consul <= 1.13
  grpc_tls = 8503 // Uncomment this if Consul > 1.13
}
connect {
  enabled = true
}