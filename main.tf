locals {
  deployment_id           = lower("${var.deployment_name}-${random_string.suffix.result}")
  zones                   = ["z1", "z2", "z3"]
  consul_auth_method_name = "nomad-workloads"
  consul_datacenters      = ["sg", "my"]
  consul_elb_ports        = ["8501", "9501"]
  nomad_elb_ports         = ["8080", "9090"]
  nomad_node_pools        = ["dev", "sit"]
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "random_id" "gossip_key" {
  byte_length = 32
}

module "infra_aws" {
  source          = "./modules/infra_aws"
  deployment_id   = local.deployment_id
  owner           = var.owner
  vpc_cidr        = var.aws_vpc_cidr
  public_subnets  = var.aws_public_subnets
  private_subnets = var.aws_private_subnets
  instance_type   = var.aws_instance_type
}

module "vault" {
  source             = "./modules/vault"
  consul_datacenters = toset(local.consul_datacenters)
  elb_http_addr      = module.infra_aws.this.elb_http_addr
  depends_on         = [module.infra_aws]
  # consul_datacenter = local.consul_datacenters[0]
}


module "consul_cluster1" {
  source              = "./modules/consul"
  instance_type       = var.aws_instance_type
  owner               = var.owner
  deployment_id       = local.deployment_id
  infra_aws           = module.infra_aws.this
  consul_server_count = var.consul_server_count
  consul_client_count = var.consul_client_count
  consul_datacenter   = local.consul_datacenters[0]
  elb_listener_port   = local.consul_elb_ports[0]
  gossip_key          = random_id.gossip_key.b64_std
  zones               = local.zones
  consul_version      = var.consul_version
  vault               = module.vault.this[local.consul_datacenters[0]]
}

module "consul_cluster2" {
  source              = "./modules/consul"
  instance_type       = var.aws_instance_type
  owner               = var.owner
  deployment_id       = local.deployment_id
  infra_aws           = module.infra_aws.this
  consul_server_count = var.consul_server_count
  consul_client_count = var.consul_client_count
  consul_datacenter   = local.consul_datacenters[1]
  elb_listener_port   = local.consul_elb_ports[1]
  gossip_key          = random_id.gossip_key.b64_std
  zones               = local.zones
  consul_version      = var.consul_version
  vault               = module.vault.this[local.consul_datacenters[1]]
}

module "nomad_cluster1" {
  source = "./modules/nomad"
  providers = {
    consul = consul.cluster1
  }
  instance_type              = var.aws_instance_type
  owner                      = var.owner
  deployment_id              = local.deployment_id
  infra_aws                  = module.infra_aws.this
  nomad_server_count         = var.nomad_server_count
  nomad_client_count         = var.nomad_client_count
  nomad_region               = local.consul_datacenters[0]
  nomad_authoritative_region = local.consul_datacenters[0]
  gossip_key                 = random_id.gossip_key.b64_std
  elb_listener_port          = local.nomad_elb_ports[0]
  zones                      = local.zones
  node_pools                 = local.nomad_node_pools
  consul_datacenter          = local.consul_datacenters[0]
  consul_ca_crt              = module.consul_cluster1.consul_ca_crt
  consul_version             = var.consul_version
  consul_auth_method_name    = local.consul_auth_method_name
  depends_on                 = [null_resource.connect_ca_cluster1, module.consul_cluster1]
}

module "nomad_cluster2" {
  source = "./modules/nomad"
  providers = {
    consul = consul.cluster2
  }
  instance_type              = var.aws_instance_type
  owner                      = var.owner
  deployment_id              = local.deployment_id
  infra_aws                  = module.infra_aws.this
  nomad_server_count         = var.nomad_server_count
  nomad_client_count         = var.nomad_client_count
  nomad_region               = local.consul_datacenters[1]
  nomad_authoritative_region = local.consul_datacenters[0]
  gossip_key                 = random_id.gossip_key.b64_std
  elb_listener_port          = local.nomad_elb_ports[1]
  zones                      = local.zones
  node_pools                 = local.nomad_node_pools
  consul_datacenter          = local.consul_datacenters[1]
  consul_ca_crt              = module.consul_cluster2.consul_ca_crt
  consul_version             = var.consul_version
  consul_auth_method_name    = local.consul_auth_method_name
  depends_on                 = [null_resource.connect_ca_cluster2, module.consul_cluster2]
}

module "nomad_vault_workload_identity" {
  source          = "./modules/nomad_vault_workload_identity"
  nomad_http_addr = "https://${module.infra_aws.this.elb_http_addr}:8080"
  nomad_ca_cert   = module.infra_aws.this.ca_cert
  # consul_auth_method_name = local.consul_auth_method_name
}

module "nomad_consul_cluster1_workload_identity" {
  source = "./modules/nomad_consul_workload_identity"
  providers = {
    consul = consul.cluster1
  }
  nomad_http_addr         = "https://${module.infra_aws.this.elb_http_addr}:${local.nomad_elb_ports[0]}"
  nomad_ca_cert           = module.infra_aws.this.ca_cert
  consul_auth_method_name = local.consul_auth_method_name
}

module "nomad_consul_cluster2_workload_identity" {
  source = "./modules/nomad_consul_workload_identity"
  providers = {
    consul = consul.cluster2
  }
  nomad_http_addr         = "https://${module.infra_aws.this.elb_http_addr}:${local.nomad_elb_ports[1]}"
  nomad_ca_cert           = module.infra_aws.this.ca_cert
  consul_auth_method_name = local.consul_auth_method_name
}

resource "time_sleep" "wait_30_seconds_cluster1" {
  depends_on = [module.consul_cluster1]

  create_duration = "30s"
}

resource "time_sleep" "wait_30_seconds_cluster2" {
  depends_on = [module.consul_cluster2]

  create_duration = "30s"
}

resource "null_resource" "connect_ca_cluster1" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<-EOD
      curl -s -k https://${module.infra_aws.this.elb_http_addr}:${local.consul_elb_ports[0]}/v1/connect/ca/roots | jq '.Roots[] |(.IntermediateCerts[])+(.RootCert)' -r > ${path.root}/generated/connect_ca_${local.consul_datacenters[0]}.crt
      EOD
  }
  depends_on = [time_sleep.wait_30_seconds_cluster1]
}

resource "null_resource" "connect_ca_cluster2" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<-EOD
      curl -s -k https://${module.infra_aws.this.elb_http_addr}:${local.consul_elb_ports[1]}/v1/connect/ca/roots | jq '.Roots[] |(.IntermediateCerts[])+(.RootCert)' -r > ${path.root}/generated/connect_ca_${local.consul_datacenters[1]}.crt
      EOD
  }
  depends_on = [time_sleep.wait_30_seconds_cluster2]
}

