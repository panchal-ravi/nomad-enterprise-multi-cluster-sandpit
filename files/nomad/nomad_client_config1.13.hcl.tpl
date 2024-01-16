# Full configuration options can be found at https://www.nomadproject.io/docs/configuration

name = "${node_name}"
data_dir  = "/etc/nomad.d/data"
bind_addr = "${private_ip}"

region ="${nomad_region}"
datacenter = "${nomad_datacenter}"
log_level = "INFO"
log_file  = "/var/log/nomad/nomad.log"

advertise {
  # Defaults to the first private IP address.
  http = "${private_ip}" # must be reachable by Nomad CLI clients
  rpc  = "${private_ip}" # must be reachable by Nomad client nodes
  // serf = "${private_ip}" # must be reachable by Nomad server nodes, not required by client
}

ports {
  http = 4646
  rpc  = 4647
  // serf = 4648 //Not required by client
}

tls {
  http = true
  rpc  = true

  ca_file   = "/etc/nomad.d/tls/ca.crt"
  cert_file = "/etc/nomad.d/tls/nomad.crt"
  key_file  = "/etc/nomad.d/tls/nomad.key"

  verify_server_hostname = true
  verify_https_client    = false
}

server {
  enabled = false
}

client {
  enabled = true
  // server_join {
  //   retry_join = ["provider=aws tag_key=nomad_cluster_region tag_value=${nomad_region}"]
  // }
} 

plugin "docker" {
  config {
    allow_privileged = true
  }
}

# Enable and configure ACLs
acl {
  enabled    = true
  token_ttl  = "30s"
  policy_ttl = "60s"
  role_ttl   = "60s"
}


# [optional] Specifies configuration for connecting to Consul
consul { 
  address = "127.0.0.1:8501"
  // address = "${private_ip}:8501"
  grpc_address = "127.0.0.1:8502"  // uncomment this if Consul <= 1.13
  // grpc_address = "127.0.0.1:8503" // uncomment this if Consul > 1.13
  // grpc_address = "${private_ip}:8503"
  ssl = true
  // verify_ssl = false
  token = "${consul_token}"
  ca_file = "/etc/consul.d/tls/connect_ca.crt" // This needs to be replaced with Connect CA
  // grpc_ca_file = "/etc/consul.d/tls/connect_ca.crt" // Comment this for Consul <= 1.13
}

# [optional] Specifies configuration for connecting to Vault
// vault {
//   enabled     = true
//   address     = "https://vault.example.com:8200"
//   create_from_role = "nomad-cluster"
// }