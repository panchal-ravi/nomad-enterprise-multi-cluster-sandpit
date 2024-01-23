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
  serf = "${private_ip}" # must be reachable by Nomad server nodes
}

ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}


server {
  enabled          = true
  encrypt          = "${gossip_key}" 
  bootstrap_expect = ${server_count}
  redundancy_zone  = "${zone}"
  authoritative_region = "${nomad_authoritative_region}"
  
  // %{ if nomad_region == nomad_authoritative_region ~}
  // server_join {
  //   retry_join = ["provider=aws tag_key=nomad_role tag_value=server_${nomad_region}"]
  // }
  // %{ endif ~}

  %{ if nomad_region != nomad_authoritative_region ~}
  server_join {
    retry_join = ["provider=aws tag_key=nomad_role tag_value=server_${nomad_region}", "provider=aws tag_key=nomad_role tag_value=server_${nomad_authoritative_region}"]
  }
  %{ endif ~}

  # license_path is required for Nomad Enterprise as of Nomad v1.1.1+
  license_path = "/etc/nomad.d/license.hclic"
}

autopilot {
  enable_redundancy_zones   = true
}

# TLS configurations
tls {
  http = true
  rpc  = true

  ca_file   = "/etc/nomad.d/tls/ca.crt"
  cert_file = "/etc/nomad.d/tls/nomad.crt"
  key_file  = "/etc/nomad.d/tls/nomad.key"

  verify_server_hostname = true
  verify_https_client    = false
}


client {
  enabled = false
} 

# Enable and configure ACLs
acl {
  enabled    = true
  token_ttl  = "30s"
  policy_ttl = "60s"
  role_ttl   = "60s"
  replication_token = "${replication_token}"
}

# [optional] Specifies configuration for connecting to Consul
consul { 
  address = "127.0.0.1:8501"
  ssl = true
  token = "${consul_token}"
  ca_file = "/etc/consul.d/tls/connect_ca.crt" //this needs to be replaced with Connect CA

  service_identity {
    aud = ["consul.io"]
    ttl = "1h"
  }

  task_identity {
    aud = ["consul.io"]
    ttl = "1h"
    env = true
    file = true
  }
}

# [optional] Specifies configuration for connecting to Vault
vault {
  name        = "default" //Name of vault cluster that can be referred in job specification file.
  enabled     = true

  // Default workload identity that is automatically added to jobs that need access to Vault. 
  // Without this identity, you would need to define an identity block in your jobs for every task that needs access to Vault.
  
  default_identity {
    aud = ["nomad.io"]
    ttl = "1h"
    env = true
    file = true
  }

  // Below parameters are not applicable for Nomad Server agents
  // address     = "https://{vault_ip}:8200"
  // ca_file     = "/etc/nomad.d/tls/ca.crt"
  // create_from_role = "nomad-cluster"
}

audit {
  enabled = true

  sink "audit" {
    type               = "file"
    delivery_guarantee = "best-effort"
    format             = "json"
    path               = "/var/log/nomad/audit/audit.log"
    rotate_bytes       = 10240000 
    rotate_duration    = "24h"
    rotate_max_files   = 10
    mode               = "0600"
  }

  # Filter out all requests and all stages for /v1/metrics
  filter "default" {
    type       = "HTTPEvent"
    endpoints  = ["/v1/metrics"]
    stages     = ["*"]
    operations = ["*"]
  }

  # Filter out requests where endpoint matches globbed pattern
  filter "globbed example" {
    type       = "HTTPEvent"
    endpoints  = ["/v1/evaluation/*/allocations"]
    stages     = ["*"]
    operations = ["*"]
  }

  # Filter out OperationReceived GET requests for all endpoints
  filter "OperationReceived GETs" {
    type       = "HTTPEvent"
    endpoints  = ["*"]
    stages     = ["OperationReceived"]
    operations = ["GET"]
  }
}